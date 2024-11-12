# How to Locally Build the Image

## Prerequisites

-  Install Debian Live-Build.

If you are using Ubuntu, do not use the provided package, as it is outdated. Instead, manually install the version used by the GitHub workflows.

```bash
curl  --location http://deb.debian.org/debian/pool/main/l/live-build/live-build_20230502_all.deb --output /tmp/live-build_20230502_all.deb

dpkg -i /tmp/live-build_20230502_all.deb
````

## Local Build Process

- Change into the Git directory.
- execute workflow_local.sh

```bash
./debian/workflow_local.sh
```

- image will be build in directory ~/build

### local package cache

- using a local caching proxy like apt-cacher-ng

```bash
apt get install apt-cacher-ng

export LB_APT_HTTP_PROXY="http://localhost:3142"
./debian/workflow_local.sh
```

### squashfs compression

- reducing the defined DEBIAN_SQUASHFS_COMPRESSION_LEVEL in build.env reduces the time to build

DEBIAN_SQUASHFS_COMPRESSION_LEVEL="1"
