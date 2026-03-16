# FreeBSD GPT Partition Label Guide

## Problem

FreeBSD disk device names (e.g., `nda0`, `nda1`) may change when:

- Adding or removing disks
- Changing BIOS/UEFI settings
- Hardware probe order changes

If `/etc/fstab` uses device names (e.g., `/dev/nda0p2`), the system will fail to boot when device names change.

## Solution

Use GPT partition labels instead of device names. Labels are persistent identifiers that remain stable regardless of device name changes.

## Steps

### 1. View Current Partition Layout

```sh
gpart show -l
```

Example output:
```
=>        40  2000409184  nda0  GPT  (954G)
          40     1048576     1  efifs  (512M)
     1048616  1998585856     2  rootfs  (953G)
```

### 2. Add Labels to Partitions

Syntax:
```sh
gpart modify -i <partition_number> -l <label_name> <disk_device>
```

Examples:
```sh
# Label the EFI partition
gpart modify -i 1 -l efifs nda0

# Label the root partition
gpart modify -i 2 -l rootfs nda0

# Label swap partition (if exists)
gpart modify -i 3 -l swapfs nda0
```

### 3. Verify Labels

```sh
gpart show -l
ls /dev/gpt/
```

### 4. Update /etc/fstab

Replace device names with label paths:

Before:
```
/dev/nda0p2    /          ufs      rw    1    1
/dev/nda0p1    /boot/efi  msdosfs  rw    2    2
```

After:
```
/dev/gpt/rootfs    /          ufs      rw    1    1
/dev/gpt/efifs     /boot/efi  msdosfs  rw    2    2
```

### 5. Reboot to Verify

```sh
reboot
```

## Suggested Label Names

| Partition Type | Suggested Label |
|----------------|-----------------|
| EFI System     | `efifs`         |
| Root Filesystem| `rootfs`        |
| Swap           | `swapfs`        |
| Data           | `datafs`        |
| ZFS Pool       | `zfspool`       |

## Recovery

If the system fails to boot:

1. Boot from FreeBSD installation USB, select Live CD or Shell
2. Mount root partition:
   ```sh
   mount /dev/nda0p2 /mnt
   ```
3. Edit fstab:
   ```sh
   vi /mnt/etc/fstab
   ```
4. Add partition labels and update fstab (follow steps above)
5. Reboot

## Notes

- Labels are case-sensitive
- Maximum label length: 15 characters
- Use simple alphanumeric names
- Always backup fstab before editing
