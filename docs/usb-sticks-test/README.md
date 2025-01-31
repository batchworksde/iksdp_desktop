# USB Stick test

Here we are testing some USB Sticks and their performance.

## test setup

All tests have been done using the bosgame hardware. All were tested on USB3 USB-A port in front of the device and using ext4 filesystem on the device, not using partitions. 

fio tool have to be installed once

```bash
apt update && apt install fio -y
```

```bash
mkfs.ext4 /dev/sda
````

All tests were just run once because of time issues.

We are using a command to write seq. to the drive using dd

```bash
dd if=/dev/random of=/mnt/testfile.dd bs=1M count=10000 status=progress
```

- we are creating fio testfile /tmp/test.fio

```
[global]
ioengine=libaio              # Asynchronous I/O
direct=1                     # Bypass the cache for accurate measurements
time_based=1                 # Tests are time-based
size=10G                     # Data size per file
filename=/mnt/testfile.fio   # Test file on the USB stick
randrepeat=0                 # No random pattern repetition

[read_test]
bs=4k                        # Block size 4 KB
iodepth=32                   # I/O queue depth
rw=read                      # Sequential read test
runtime=120                  # Duration: 120 seconds

[write_test]
bs=4k
iodepth=32
rw=write                     # Sequential write test
runtime=120                  # Duration: 120 seconds

[random_read]
bs=4k
iodepth=32
rw=randread                  # Random read test
runtime=120                  # Duration: 120 seconds

[random_write]
bs=4k
iodepth=32
rw=randwrite                 # Random write test
runtime=120                  # Duration: 120 seconds
```

and start it using 

```bash
fio /tmp/test.fio --output-format=json
```

We document dmesg from plugin in and check it after the test for errors.

### SMI USB DISK

- aka.: Sojus Stick
- feels to slow when using the desktop
- dmesg

```
[ 6889.343910] usb 4-1: new SuperSpeed USB device number 2 using xhci_hcd
[ 6889.365160] usb 4-1: New USB device found, idVendor=090c, idProduct=2000, bcdDevice=11.00
[ 6889.365178] usb 4-1: New USB device strings: Mfr=1, Product=2, SerialNumber=0
[ 6889.365185] usb 4-1: Product: USB DISK
[ 6889.365189] usb 4-1: Manufacturer: SMI Corporation
[ 6889.494624] usb-storage 4-1:1.0: USB Mass Storage device detected
[ 6889.495042] usb-storage 4-1:1.0: Quirks match for vid 090c pid 2000: 800000
[ 6889.495157] scsi host2: usb-storage 4-1:1.0
[ 6890.569732] scsi 2:0:0:0: Direct-Access     SMI      USB DISK         1100 PQ: 0 ANSI: 6
[ 6890.570470] sd 2:0:0:0: Attached scsi generic sg1 type 0
[ 6890.571347] sd 2:0:0:0: [sda] 61440000 512-byte logical blocks: (31.5 GB/29.3 GiB)
[ 6890.571538] sd 2:0:0:0: [sda] Write Protect is off
[ 6890.571547] sd 2:0:0:0: [sda] Mode Sense: 43 00 00 00
[ 6890.571825] sd 2:0:0:0: [sda] Write cache: enabled, read cache: enabled, doesn't support DPO or FUA
[ 6890.574860] sd 2:0:0:0: [sda] Attached SCSI removable disk
[ 6890.814368] EXT4-fs (sda): mounted filesystem with ordered data mode. Quota mode: none.
```

```
root@iksdp-0:~# dd if=/dev/random of=/mnt/testfile.dd bs=1M count=10000 status=progress
10000+0 records in
10000+0 records out
10485760000 bytes (10 GB, 9.8 GiB) copied, 256.915 s, 40.8 MB/s
```

### ORICO UFSD-X 128GB


- [Amazon](https://www.amazon.de/gp/product/B0BHZ55ZCQ)
- [ssd-tester](https://ssd-tester.de/orico_ufsd-x_256gb.html) - only 256 GB Version listed
- feels fast enough
- dmesg

```
[ 9829.832864] usb 4-2: new SuperSpeed USB device number 3 using xhci_hcd
[ 9829.851449] usb 4-2: New USB device found, idVendor=152d, idProduct=0562, bcdDevice= 3.03
[ 9829.851467] usb 4-2: New USB device strings: Mfr=1, Product=2, SerialNumber=3
[ 9829.851474] usb 4-2: Product: UFSD-X
[ 9829.851478] usb 4-2: Manufacturer: ORICO
[ 9829.851482] usb 4-2: SerialNumber: DD56419884268
[ 9829.853553] usb-storage 4-2:1.0: USB Mass Storage device detected
[ 9829.854645] scsi host2: usb-storage 4-2:1.0
[ 9830.949136] scsi 2:0:0:0: Direct-Access     ORICO    UFSD-X           0303 PQ: 0 ANSI: 6
[ 9830.949765] sd 2:0:0:0: Attached scsi generic sg1 type 0
[ 9830.950830] sd 2:0:0:0: [sda] 250052601 512-byte logical blocks: (128 GB/119 GiB)
[ 9830.951151] sd 2:0:0:0: [sda] Write Protect is off
[ 9830.951163] sd 2:0:0:0: [sda] Mode Sense: 43 00 00 00
[ 9830.951343] sd 2:0:0:0: [sda] Write cache: disabled, read cache: enabled, doesn't support DPO or FUA
[ 9830.959666] sd 2:0:0:0: [sda] Attached SCSI removable disk
```

```
root@iksdp-0:~# dd if=/dev/random of=/mnt/testfile.dd bs=1M count=10000 status=progress
10464788480 bytes (10 GB, 9.7 GiB) copied, 216 s, 48.4 MB/s
10000+0 records in
10000+0 records out
10485760000 bytes (10 GB, 9.8 GiB) copied, 216.57 s, 48.4 MB/s
```

### SSK 128GB

- [Amazon](https://www.amazon.de/gp/product/B0C36C8WCX)
- [ssd-tester](https://ssd-tester.de/ssk_sd301_128gb.html)
- feels super fast
- dmesg

```
[10678.583164] usb 4-2: USB disconnect, device number 3
[10703.986682] usb 4-2: new SuperSpeed USB device number 4 using xhci_hcd
[10704.015360] usb 4-2: New USB device found, idVendor=2109, idProduct=0715, bcdDevice= 2.63
[10704.015379] usb 4-2: New USB device strings: Mfr=1, Product=2, SerialNumber=3
[10704.015385] usb 4-2: Product: SSK USB3.2 SSD Flash Drive
[10704.015390] usb 4-2: Manufacturer: SSK Corporation
[10704.015394] usb 4-2: SerialNumber: ABCDEFA90767
[10704.022069] scsi host2: uas
[10704.033052] scsi 2:0:0:0: Direct-Access     SSK Port able SSD 128     X042 PQ: 0 ANSI: 6
[10704.038957] sd 2:0:0:0: Attached scsi generic sg1 type 0
[10704.039284] sd 2:0:0:0: [sda] 250069680 512-byte logical blocks: (128 GB/119 GiB)
[10704.039442] sd 2:0:0:0: [sda] Write Protect is off
[10704.039446] sd 2:0:0:0: [sda] Mode Sense: 2f 00 00 00
[10704.039740] sd 2:0:0:0: [sda] Write cache: enabled, read cache: enabled, doesn't support DPO or FUA
[10704.086535] sd 2:0:0:0: [sda] Preferred minimum I/O size 4096 bytes
[10704.086539] sd 2:0:0:0: [sda] Optimal transfer size 33553920 bytes not a multiple of preferred minimum block size (4096 bytes)
[10704.088470] sd 2:0:0:0: [sda] Attached SCSI disk
```

```
root@iksdp-0:~# dd if=/dev/random of=/mnt/testfile.dd bs=1M count=10000 status=progress
10278141952 bytes (10 GB, 9.6 GiB) copied, 31 s, 332 MB/s
10000+0 records in
10000+0 records out
10485760000 bytes (10 GB, 9.8 GiB) copied, 31.6296 s, 332 MB/s
```

### sandisk Ultra Flair 64GB

- [Amazon](https://www.amazon.de/SanDisk-Ultra-Flair-USB-Flash-Laufwerk-150-MB/dp/B015CH1NAQ)
- [ssd-tester](https://ssd-tester.de/sandisk_ultra_flair_64gb_usb_3_0.html)
- not (yet) tested in desktop mode
- dmesg

```
[11213.580712] usb 4-2: new SuperSpeed USB device number 5 using xhci_hcd
[11213.601844] usb 4-2: New USB device found, idVendor=0781, idProduct=5591, bcdDevice= 1.00
[11213.601862] usb 4-2: New USB device strings: Mfr=1, Product=2, SerialNumber=3
[11213.601869] usb 4-2: Product:  SanDisk 3.2Gen1
[11213.601874] usb 4-2: Manufacturer:  USB
[11213.601877] usb 4-2: SerialNumber: 0401c9fcf6a6f3e4971ce71b5523a65cfd1677f2a361d5f3e80faa3ef1ed3e1a1de800000000000000000000dbcefc61008e801891558107a8b0180f
[11213.603861] usb-storage 4-2:1.0: USB Mass Storage device detected
[11213.604980] scsi host2: usb-storage 4-2:1.0
[11214.626194] scsi 2:0:0:0: Direct-Access      USB      SanDisk 3.2Gen1 1.00 PQ: 0 ANSI: 6
[11214.626776] sd 2:0:0:0: Attached scsi generic sg1 type 0
[11214.631278] sd 2:0:0:0: [sda] 120164352 512-byte logical blocks: (61.5 GB/57.3 GiB)
[11214.632133] sd 2:0:0:0: [sda] Write Protect is off
[11214.632140] sd 2:0:0:0: [sda] Mode Sense: 43 00 00 00
[11214.632478] sd 2:0:0:0: [sda] Write cache: disabled, read cache: enabled, doesn't support DPO or FUA
[11214.637904]  sda: sda1
[11214.638010] sd 2:0:0:0: [sda] Attached SCSI removable disk
```

```
root@iksdp-0:~# dd if=/dev/random of=/mnt/testfile.dd bs=1M count=10000 status=progress
10475274240 bytes (10 GB, 9.8 GiB) copied, 363 s, 28.9 MB/s
10000+0 records in
10000+0 records out
10485760000 bytes (10 GB, 9.8 GiB) copied, 363.797 s, 28.8 MB/s
```

### ORICO U3S-X 64GB

- [Amazon](https://www.amazon.de/ORICO-0-Flash-Laufwerk-Schl%C3%BCsselschalter-USB-Speichermedien-Kompatibler-U3-100M-S/dp/B0BHZ5ZM42)
- [ssd-tester](https://ssd-tester.de/orico_u3s_64gb.html) - unclear of it's really the stick - picture does not match
- not tested yet
- dmesg

```
[13348.994266] EXT4-fs (sda): unmounting filesystem.
[13362.903933] usb 4-2: USB disconnect, device number 5
[13365.735977] usb 4-2: new SuperSpeed USB device number 6 using xhci_hcd
[13365.757389] usb 4-2: New USB device found, idVendor=090c, idProduct=1000, bcdDevice=11.00
[13365.757407] usb 4-2: New USB device strings: Mfr=1, Product=2, SerialNumber=3
[13365.757414] usb 4-2: Product: U3S-X
[13365.757419] usb 4-2: Manufacturer: ORICO
[13365.757423] usb 4-2: SerialNumber: AA00000000015589
[13365.822244] usb-storage 4-2:1.0: USB Mass Storage device detected
[13365.822933] scsi host2: usb-storage 4-2:1.0
[13368.175684] scsi 2:0:0:0: Direct-Access     ORICO    U3S-X            1100 PQ: 0 ANSI: 6
[13368.176500] sd 2:0:0:0: Attached scsi generic sg1 type 0
[13368.177589] sd 2:0:0:0: [sda] 120927318 512-byte logical blocks: (61.9 GB/57.7 GiB)
[13368.177886] sd 2:0:0:0: [sda] Write Protect is off
[13368.177894] sd 2:0:0:0: [sda] Mode Sense: 43 00 00 00
[13368.178044] sd 2:0:0:0: [sda] Write cache: enabled, read cache: enabled, doesn't support DPO or FUA
[13368.180429]  sda: sda1
[13368.180647] sd 2:0:0:0: [sda] Attached SCSI removable disk
[21931.641615] EXT4-fs (sda1): recovery complete
[21931.642710] EXT4-fs (sda1): mounted filesystem with ordered data mode. Quota mode: none.
[23138.285068] EXT4-fs (sda1): unmounting filesystem.
```

```
root@iksdp-0:~# dd if=/dev/random of=/mnt/testfile.dd bs=1M count=10000 status=progress
10465837056 bytes (10 GB, 9.7 GiB) copied, 191 s, 54.8 MB/s
10000+0 records in
10000+0 records out
10485760000 bytes (10 GB, 9.8 GiB) copied, 191.509 s, 54.8 MB/s
```

### ORICO UFSD 64GB

- [Amazon](https://www.amazon.de/gp/product/B0BHZ55H6B)
- [ssd-tester](https://ssd-tester.de/orico_ufsd-x_256gb.html) - only 256 GB Version listed
- not tested yet
- dmesg

```
[  311.333615] usb 4-2: USB disconnect, device number 2
[  314.572613] usb 4-2: new SuperSpeed USB device number 3 using xhci_hcd
[  314.593478] usb 4-2: New USB device found, idVendor=152d, idProduct=0562, bcdDevice= 3.03
[  314.593496] usb 4-2: New USB device strings: Mfr=1, Product=2, SerialNumber=3
[  314.593503] usb 4-2: Product: UFSD-X
[  314.593508] usb 4-2: Manufacturer: ORICO
[  314.593511] usb 4-2: SerialNumber: DD56419884271
[  314.595760] usb-storage 4-2:1.0: USB Mass Storage device detected
[  314.598434] scsi host2: usb-storage 4-2:1.0
[  315.645245] scsi 2:0:0:0: Direct-Access     ORICO    UFSD-X           0303 PQ: 0 ANSI: 6
[  315.646036] sd 2:0:0:0: Attached scsi generic sg1 type 0
[  315.646959] sd 2:0:0:0: [sda] 124960761 512-byte logical blocks: (64.0 GB/59.6 GiB)
[  315.647181] sd 2:0:0:0: [sda] Write Protect is off
[  315.647188] sd 2:0:0:0: [sda] Mode Sense: 43 00 00 00
[  315.647352] sd 2:0:0:0: [sda] Write cache: disabled, read cache: enabled, doesn't support DPO or FUA
[  315.654025] sd 2:0:0:0: [sda] Attached SCSI removable disk
[  315.874051] EXT4-fs (sda): mounted filesystem with ordered data mode. Quota mode: none.
```

```
root@iksdp-0:~# dd if=/dev/random of=/mnt/testfile.dd bs=1M count=10000 status=progress
10377756672 bytes (10 GB, 9.7 GiB) copied, 43 s, 241 MB/s
10000+0 records in
10000+0 records out
10485760000 bytes (10 GB, 9.8 GiB) copied, 43.5615 s, 241 MB/s
```


### current results

|filename                        |random_read|random_write|read_test|write_test|description         |
|--------------------------------|-----------|------------|---------|----------|--------------------|
|fio.orico_u3sx_64gb.json        |40         |45          |1081     |876       | not yet tested     | 
|fio.orico_ufsd_128gb.json       |366        |434         |8946     |7849      | tested - fast      |
|fio.orico_ufsd_64 gb.json       |406        |460         |10629    |9301      | not tested         |
|fio.sandisk_ultraflair_64gb.json|43         |44          |1067     |878       | not yet tested     |
|fio.smi.json                    |5          |5           |132      |109       | tested - to slow   |
|fio.ssk_128gb.json              |9268       |5924        |7259     |5056      | tested - superfast |


## generate fio results

you can use

```bash
./printresults.sh
```

```
./printresults.sh
{
  "filename": "fio.orico_u3sx_64gb.json",
  "jobname": "read_test",
  "iops_read": 1080.961269,
  "runtime_read": 120008,
  "iops_write": 0,
  "runtime_write": 0
}
{
  "filename": "fio.orico_u3sx_64gb.json",
  "jobname": "write_test",
  "iops_read": 0,
  "runtime_read": 0,
  "iops_write": 875.561444,
  "runtime_write": 120003
}
{
  "filename": "fio.orico_u3sx_64gb.json",
  "jobname": "random_read",
  "iops_read": 39.522695,
  "runtime_read": 120007,
  "iops_write": 0,
  "runtime_write": 0
}
{
  "filename": "fio.orico_u3sx_64gb.json",
  "jobname": "random_write",
  "iops_read": 0,
  "runtime_read": 0,
  "iops_write": 44.59777,
  "runtime_write": 120006
}
{
  "filename": "fio.orico_ufsd_128gb.json",
  "jobname": "read_test",
  "iops_read": 8946.067566,
  "runtime_read": 120002,
  "iops_write": 0,
  "runtime_write": 0
}
{
  "filename": "fio.orico_ufsd_128gb.json",
  "jobname": "write_test",
  "iops_read": 0,
  "runtime_read": 0,
  "iops_write": 7848.627523,
  "runtime_write": 120002
}
{
  "filename": "fio.orico_ufsd_128gb.json",
  "jobname": "random_read",
  "iops_read": 366.260562,
  "runtime_read": 120002,
  "iops_write": 0,
  "runtime_write": 0
}
{
  "filename": "fio.orico_ufsd_128gb.json",
  "jobname": "random_write",
  "iops_read": 0,
  "runtime_read": 0,
  "iops_write": 434.247477,
  "runtime_write": 120003
}
{
  "filename": "fio.sandisk_ultraflair_64gb.json",
  "jobname": "read_test",
  "iops_read": 1067.105482,
  "runtime_read": 120020,
  "iops_write": 0,
  "runtime_write": 0
}
{
  "filename": "fio.sandisk_ultraflair_64gb.json",
  "jobname": "write_test",
  "iops_read": 0,
  "runtime_read": 0,
  "iops_write": 877.804531,
  "runtime_write": 120029
}
{
  "filename": "fio.sandisk_ultraflair_64gb.json",
  "jobname": "random_read",
  "iops_read": 43.159114,
  "runtime_read": 120021,
  "iops_write": 0,
  "runtime_write": 0
}
{
  "filename": "fio.sandisk_ultraflair_64gb.json",
  "jobname": "random_write",
  "iops_read": 0,
  "runtime_read": 0,
  "iops_write": 43.523541,
  "runtime_write": 120027
}
{
  "filename": "fio.smi.json",
  "jobname": "read_test",
  "iops_read": 132.0239,
  "runtime_read": 120001,
  "iops_write": 0,
  "runtime_write": 0
}
{
  "filename": "fio.smi.json",
  "jobname": "write_test",
  "iops_read": 0,
  "runtime_read": 0,
  "iops_write": 109.280601,
  "runtime_write": 120003
}
{
  "filename": "fio.smi.json",
  "jobname": "random_read",
  "iops_read": 5.481967,
  "runtime_read": 120942,
  "iops_write": 0,
  "runtime_write": 0
}
{
  "filename": "fio.smi.json",
  "jobname": "random_write",
  "iops_read": 0,
  "runtime_read": 0,
  "iops_write": 5.475775,
  "runtime_write": 121444
}
{
  "filename": "fio.ssk_128gb.json",
  "jobname": "read_test",
  "iops_read": 7259.308023,
  "runtime_read": 120004,
  "iops_write": 0,
  "runtime_write": 0
}
{
  "filename": "fio.ssk_128gb.json",
  "jobname": "write_test",
  "iops_read": 0,
  "runtime_read": 0,
  "iops_write": 5056.490725,
  "runtime_write": 120002
}
{
  "filename": "fio.ssk_128gb.json",
  "jobname": "random_read",
  "iops_read": 9268.193295,
  "runtime_read": 120003,
  "iops_write": 0,
  "runtime_write": 0
}
{
  "filename": "fio.ssk_128gb.json",
  "jobname": "random_write",
  "iops_read": 0,
  "runtime_read": 0,
  "iops_write": 5924.235859,
  "runtime_write": 120004
}
```

- reformatting might work without splunk..

```
index="teststick" sourcetype="_json" 
| eval iops = round(if(match(jobname,"read"),iops_read,if(match(jobname,"write"),iops_write,"n/a")))
| stats values(iops) as iops by filename jobname
| xyseries filename jobname iops
```

- direct csv export is possible with [yq](https://mikefarah.gitbook.io/yq/usage/csv-tsv#encode-array-of-objects-to-csv-missing-fields-behaviour)

```bash
for file in *.json; do file=$file yq -o csv '[["filename", "jobname", "read_iops", "read_runtime", "write_iops", "write_runtime"]] + [.jobs[] | [strenv(file), .jobname, .read.iops, .read.runtime, .write.iops, .write.runtime ]]' $file; done | sort --unique
```

```csv
filename,jobname,read_iops,read_runtime,write_iops,write_runtime
fio.orico_u3sx_64gb.json,random_read,39.522695,120007,0,0
fio.orico_u3sx_64gb.json,random_write,0,0,44.59777,120006
fio.orico_u3sx_64gb.json,read_test,1080.961269,120008,0,0
fio.orico_u3sx_64gb.json,write_test,0,0,875.561444,120003
fio.orico_ufsd_128gb.json,random_read,366.260562,120002,0,0
fio.orico_ufsd_128gb.json,random_write,0,0,434.247477,120003
fio.orico_ufsd_128gb.json,read_test,8946.067566,120002,0,0
fio.orico_ufsd_128gb.json,write_test,0,0,7848.627523,120002
fio.sandisk_ultraflair_64gb.json,random_read,43.159114,120021,0,0
fio.sandisk_ultraflair_64gb.json,random_write,0,0,43.523541,120027
fio.sandisk_ultraflair_64gb.json,read_test,1067.105482,120020,0,0
fio.sandisk_ultraflair_64gb.json,write_test,0,0,877.804531,120029
fio.smi.json,random_read,5.481967,120942,0,0
fio.smi.json,random_write,0,0,5.475775,121444
fio.smi.json,read_test,132.0239,120001,0,0
fio.smi.json,write_test,0,0,109.280601,120003
fio.ssk_128gb.json,random_read,9268.193295,120003,0,0
fio.ssk_128gb.json,random_write,0,0,5924.235859,120004
fio.ssk_128gb.json,read_test,7259.308023,120004,0,0
fio.ssk_128gb.json,write_test,0,0,5056.490725,120002
```
