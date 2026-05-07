#!/bin/bash
# telemetry.sh
# Sends telemetry data to a Splunk HTTP Event Collector (HEC).
#
# Usage:
#   telemetry.sh --boot                   One-time boot event (hardware inventory + runtime metrics)
#   telemetry.sh --heartbeat              Periodic heartbeat (runtime metrics only)
#   telemetry.sh --boot --dry-run         Dry-run: print payload to stdout, do not send
#   telemetry.sh --heartbeat --dry-run    Dry-run: print payload to stdout, do not send
#   telemetry.sh --boot --dry-run --log /tmp/telemetry.log
#                                         Dry-run: write payload to log file instead of stdout

# ─────────────────────────── Configuration ───────────────────────────
SPLUNK_HEC_URL="https://splunk.example.com:8088/services/collector/event"
SPLUNK_HEC_TOKEN="YOUR-HEC-TOKEN-HERE"
SPLUNK_INDEX="linux_telemetry"
MAX_RETRIES=3
RETRY_DELAY=10

# Directories checked for the .disable_telemetry kill-switch file.
# The home directory of the live user is appended automatically at runtime.
DISABLE_FILE_DIRS=(
    "/opt/iksdp/etc"
)

# If set to "true", telemetry will not be sent when running inside a
# virtual machine (as detected by systemd-detect-virt). The virt type
# is still collected and included in the payload for dry-run inspection.
SKIP_IF_VIRTUAL="true"

# ──────────────────── Resolve live username from kernel cmdline ──────
LIVE_CONFIG_CMDLINE="${LIVE_CONFIG_CMDLINE:-$(cat /proc/cmdline)}"
for _PARAMETER in ${LIVE_CONFIG_CMDLINE}; do
    case "${_PARAMETER}" in
        live-config.username=*|username=*)
            LIVE_USERNAME="${_PARAMETER#*username=}"
            ;;
    esac
done

# ──────────────────────── Kill-switch check ──────────────────────────
if [[ -n "$LIVE_USERNAME" ]]; then
    LIVE_USER_HOME=$(getent passwd "$LIVE_USERNAME" | cut -d: -f6)
    DISABLE_FILE_DIRS+=("$LIVE_USER_HOME")
else
    logger -t telemetry "Warning: could not determine live username from kernel cmdline."
fi

for dir in "${DISABLE_FILE_DIRS[@]}"; do
    if [[ -f "${dir}/.disable_iksdp_telemetry" ]]; then
        logger -t telemetry "Telemetry disabled via ${dir}/.disable_iksdp_telemetry – exiting."
        exit 0
    fi
done

# ───────────────────────────── Argument parser ───────────────────────
MODE=""
DRY_RUN=false
LOG_FILE=""

while [[ $# -gt 0 ]]; do
    case "$1" in
        --boot)      MODE="boot" ;;
        --heartbeat) MODE="heartbeat" ; MAX_RETRIES=2 ;;
        --dry-run)   DRY_RUN=true ;;
        --log)
            shift
            LOG_FILE="$1"
            ;;
        *)
            echo "Usage: $0 --boot|--heartbeat [--dry-run] [--log <file>]" >&2
            exit 1
            ;;
    esac
    shift
done

if [[ -z "$MODE" ]]; then
    echo "Usage: $0 --boot|--heartbeat [--dry-run] [--log <file>]" >&2
    exit 1
fi

# --log without --dry-run is silently ignored
if [[ -n "$LOG_FILE" && "$DRY_RUN" == false ]]; then
    echo "Warning: --log has no effect without --dry-run" >&2
fi

SPLUNK_SOURCETYPE="debian_live_${MODE}"

# ────────────────────── Virtualisation detection ─────────────────────
VIRT_TYPE=$(systemd-detect-virt 2>/dev/null || echo "unknown")

if [[ "$SKIP_IF_VIRTUAL" == "true" && "$VIRT_TYPE" != "none" && "$DRY_RUN" == false ]]; then
    logger -t telemetry "Running in VM (${VIRT_TYPE}) – telemetry skipped (SKIP_IF_VIRTUAL=true)."
    exit 0
fi

# ──────────────────────── Device identification ──────────────────────
# Use the last 3 octets of the primary interface MAC as a short device ID.
# The full MAC is still included separately in the payload.
# This is necessary because all machines share the same hostname.
PRIMARY_IFACE=$(ip link show | awk '/^[0-9]+: /{iface=$2} /link\/ether /{print iface; exit}' | tr -d ':')
PRIMARY_MAC=$(ip link show "${PRIMARY_IFACE%:}" 2>/dev/null | awk '/link\/ether/{print $2}')
[[ -z "$PRIMARY_MAC" ]] && PRIMARY_MAC=$(cat /sys/class/net/*/address 2>/dev/null | grep -v '00:00:00:00:00:00' | head -1)
PRIMARY_MAC_COMPACT="${PRIMARY_MAC//:/}"
DEVICE_ID="live-${PRIMARY_MAC_COMPACT:6:6}"
[[ -z "${PRIMARY_MAC_COMPACT}" ]] && DEVICE_ID="unknown"

# ─────────────────────────── Shared fields ───────────────────────────
TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
HOSTNAME=$(hostname)
ALL_IPS=$(hostname -I 2>/dev/null | tr ' ' ',')
UPTIME_SECS=$(awk '{print int($1)}' /proc/uptime)
UPTIME_HUMAN=$(uptime -p 2>/dev/null || echo "unknown")

# Memory
RAM_TOTAL_MB=$(awk '/MemTotal/{printf "%d", $2/1024}' /proc/meminfo)
RAM_FREE_MB=$(awk '/MemAvailable/{printf "%d", $2/1024}' /proc/meminfo)
RAM_USED_MB=$(( RAM_TOTAL_MB - RAM_FREE_MB ))
RAM_USED_PCT=$(awk "BEGIN {printf \"%.1f\", ${RAM_USED_MB}/${RAM_TOTAL_MB}*100}")

# CPU
CPU_CORES=$(nproc)
CPU_LOAD_1=$(awk '{print $1}' /proc/loadavg)
CPU_LOAD_5=$(awk '{print $2}' /proc/loadavg)
CPU_LOAD_15=$(awk '{print $3}' /proc/loadavg)

# Disk
DISK_ROOT_FREE=$(df -m / 2>/dev/null | awk 'NR==2{print $4}')
DISK_ROOT_USED_PCT=$(df / 2>/dev/null | awk 'NR==2{print $5}' | tr -d '%')

# Network TX/RX bytes since boot on the primary interface
IFACE_CLEAN="${PRIMARY_IFACE%:}"
NET_RX_BYTES=$(cat /sys/class/net/${IFACE_CLEAN}/statistics/rx_bytes 2>/dev/null || echo 0)
NET_TX_BYTES=$(cat /sys/class/net/${IFACE_CLEAN}/statistics/tx_bytes 2>/dev/null || echo 0)

# Processes and logged-in users
PROC_COUNT=$(ps aux --no-headers 2>/dev/null | wc -l)
LOGGED_IN_USERS=$(who | wc -l)

# Timezone and locale
TIMEZONE=$(timedatectl show --property=Timezone --value 2>/dev/null || cat /etc/timezone 2>/dev/null || echo "unknown")
LOCALE=$(locale 2>/dev/null | awk -F= '/^LANG=/{print $2}' | tr -d '"')
LOCALE="${LOCALE:-unknown}"

# ──────────────────── Boot-only fields ───────────────────────────────
BOOT_EXTRA=""
if [[ "$MODE" == "boot" ]]; then
    ALL_MACS=$(ip link show | awk '/link\/ether/{print $2}' | paste -sd, -)
    BOOT_TIME=$(who -b 2>/dev/null | awk '{print $3, $4}')
    OS_PRETTY=$(grep "^PRETTY_NAME" /etc/os-release 2>/dev/null | cut -d= -f2 | tr -d '"')
    KERNEL=$(uname -r)
    ARCH=$(uname -m)
    CPU_MODEL=$(grep -m1 "model name" /proc/cpuinfo | cut -d: -f2 | sed 's/^ *//')
    DISK_ROOT_TOTAL=$(df -m / 2>/dev/null | awk 'NR==2{print $2}')
    SERIAL=$(dmidecode -s system-serial-number 2>/dev/null | grep -v "^#" | head -1 | tr -d ' ')
    BIOS_UUID=$(dmidecode -s system-uuid 2>/dev/null | grep -v "^#" | head -1)
    SCREEN_RES=$(xrandr 2>/dev/null | awk '/ connected/{getline; print $1}' | head -1)
    SCREEN_RES="${SCREEN_RES:-unknown}"
    # IKSDP specific
    IKSDP_VERSION=$(cat /etc/iksdp_version 2>/dev/null || echo "")
    IKSDP_PERSISTENCE=$(cat /tmp/iksdp_mode 2>/dev/null || echo "")

    BOOT_EXTRA=$(cat <<BOOTEOF
        "all_macs": "${ALL_MACS}",
        "boot_time": "${BOOT_TIME}",
        "os": "${OS_PRETTY}",
        "kernel": "${KERNEL}",
        "arch": "${ARCH}",
        "cpu_model": "${CPU_MODEL}",
        "ram_total_mb": ${RAM_TOTAL_MB},
        "disk_root_total_mb": ${DISK_ROOT_TOTAL:-0},
        "serial": "${SERIAL}",
        "bios_uuid": "${BIOS_UUID}",
        "screen_resolution": "${SCREEN_RES}",
        "virt_type": "${VIRT_TYPE}",
        "iksdp_version": "${IKSDP_VERSION}",
        "iksdp_persistence": "${IKSDP_PERSISTENCE}",
BOOTEOF
)
fi

# ──────────────────────────── JSON payload ───────────────────────────
JSON_PAYLOAD=$(cat <<JSONEOF
{
    "time": $(date -u +%s),
    "host": "${DEVICE_ID}",
    "index": "${SPLUNK_INDEX}",
    "sourcetype": "${SPLUNK_SOURCETYPE}",
    "event": {
        "event_type": "${MODE}",
        "timestamp": "${TIMESTAMP}",
        "device_id": "${DEVICE_ID}",
        "hostname": "${HOSTNAME}",
        "primary_mac": "${PRIMARY_MAC}",
        "ip_addresses": "${ALL_IPS}",
        ${BOOT_EXTRA}
        "uptime_seconds": ${UPTIME_SECS},
        "uptime_human": "${UPTIME_HUMAN}",
        "cpu_cores": ${CPU_CORES},
        "cpu_load_1m": ${CPU_LOAD_1},
        "cpu_load_5m": ${CPU_LOAD_5},
        "cpu_load_15m": ${CPU_LOAD_15},
        "ram_used_mb": ${RAM_USED_MB},
        "ram_free_mb": ${RAM_FREE_MB},
        "ram_used_pct": ${RAM_USED_PCT},
        "disk_root_free_mb": ${DISK_ROOT_FREE:-0},
        "disk_root_used_pct": ${DISK_ROOT_USED_PCT:-0},
        "net_rx_bytes": ${NET_RX_BYTES},
        "net_tx_bytes": ${NET_TX_BYTES},
        "process_count": ${PROC_COUNT},
        "logged_in_users": ${LOGGED_IN_USERS},
        "timezone": "${TIMEZONE}",
        "locale": "${LOCALE}"
    }
}
JSONEOF
)

# ──────────────────────────── Dry-run output ─────────────────────────
if [[ "$DRY_RUN" == true ]]; then
    DRY_RUN_HEADER="=== DRY-RUN [$(date -u +"%Y-%m-%dT%H:%M:%SZ")] mode=${MODE} virt=${VIRT_TYPE} target=${SPLUNK_HEC_URL} ==="

    # Pretty-print JSON if python3 is available, otherwise plain output
    if command -v python3 &>/dev/null; then
        FORMATTED_PAYLOAD=$(echo "${JSON_PAYLOAD}" | python3 -m json.tool 2>/dev/null || echo "${JSON_PAYLOAD}")
    else
        FORMATTED_PAYLOAD="${JSON_PAYLOAD}"
    fi

    OUTPUT="${DRY_RUN_HEADER}"$'\n'"${FORMATTED_PAYLOAD}"$'\n'

    if [[ -n "$LOG_FILE" ]]; then
        echo "${OUTPUT}" >> "${LOG_FILE}"
        echo "Dry-run: payload written to ${LOG_FILE}"
    else
        echo "${OUTPUT}"
    fi
    exit 0
fi

# ──────────────────────────── Transmission ───────────────────────────
for attempt in $(seq 1 $MAX_RETRIES); do
    HTTP_CODE=$(curl -sk \
        -o /tmp/splunk_telemetry_response.txt \
        -w "%{http_code}" \
        -X POST "${SPLUNK_HEC_URL}" \
        -H "Authorization: Splunk ${SPLUNK_HEC_TOKEN}" \
        -H "Content-Type: application/json" \
        --connect-timeout 10 \
        --max-time 30 \
        -d "${JSON_PAYLOAD}")

    if [[ "$HTTP_CODE" == "200" ]]; then
        logger -t telemetry "[${MODE}] Event sent successfully (device_id=${DEVICE_ID})"
        exit 0
    else
        logger -t telemetry "[${MODE}] Attempt ${attempt}/${MAX_RETRIES} failed (HTTP ${HTTP_CODE}): $(cat /tmp/splunk_telemetry_response.txt)"
        [[ $attempt -lt $MAX_RETRIES ]] && sleep $RETRY_DELAY
    fi
done

logger -t telemetry "[${MODE}] ERROR: Failed to send event after ${MAX_RETRIES} attempts."
exit 1
