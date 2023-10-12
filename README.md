# Proxmox v7.4/v8 - Ryzen 7 7735HS - AMD Radeon 680M GPU passthrough

This is a guide to get the Ryzen 7 7735HS with AMD Radeon 680M integrated graphics running with proxmox inside a Windows 10 VM.

# Installing Proxmox VE
1. Download [Proxmox](https://www.proxmox.com/en/downloads/proxmox-virtual-environment/iso) and create a installation usb (with [rufus](https://rufus.ie/en/) for example)
1. Boot your PC from the USB and run the proxmox installation (in my case it's a Minis Forum UM773)
2. If installing Proxmox 7.4, you need to fix the graphical installer when it crashes (known issue in proxmox 7.4)
   - Wait until it says `Starting the installer GUI`, then press `CTRL + ALT + F3`
   - Run the following commands:
     ```
     Xorg -configure
     cp /root/xorg.conf.new /etc/X11/xorg.conf
     sed -i 's/amdgpu/fbdev/g' /etc/X11/xorg.conf
     ```
   - Press `CTRL + ALT + F1` and run `startx`
4. Complete the installation:
     - For an IPv4 static IP, type `192.168.1.XXX/24`
     - After the installation finishes, type `exit` in the terminal
6. Make sure that the web interface is working: `https://<THE_IP_YOU_CONFIGURED>:8006/`
7. Connect to the machine via SSH:
    ```
    ssh root@<THE_IP_YOU_CONFIGURED>
    ```
3. Proxmox VE comes with Enterprise repositories configured by default, [we need to switch to the non-subscription ones to get proxmox updates](https://pve.proxmox.com/wiki/Package_Repositories):
    ```
    echo "deb http://download.proxmox.com/debian/pve bullseye pve-no-subscription" >> /etc/apt/sources.list.d/pve.list
    mv /etc/apt/sources.list.d/pve-enterprise.list /etc/apt/sources.list.d/pve-enterprise.list.orig
    apt update
    ```
    
# Configuring the GPU for passthrough

The process of doing a GPU passthrough isn't complicated, it's about making sure the host doesn't load the GPU drivers and that the GPU PCI connection can be sent to the VM completely.

1. First, we need to discover the GPU PCI ID:
    ```
    lspci -nn | grep -e 'AMD/ATI'
    ```
    in my case, it looks like this:
    ```
    34:00.0 VGA compatible controller [0300]: Advanced Micro Devices, Inc. [AMD/ATI] Device [1002:1681] (rev 0a)
    34:00.1 Audio device [0403]: Advanced Micro Devices, Inc. [AMD/ATI] Device [1002:1640]
    ```
    
    From this information, we can extract some PCI IDs and device numbers. From now on, when you see these numbers in some commands, replace them with your own numbers:
    - GPU: `1002:1681` + `0000:34:00.0`
    - Audio Device: `1002:1640` + `0000:34:00.1`

1. Now, we need to enable iommu which allows the CPU to have full control of direct memory access devices (like the GPU)
    ```
    sed -i 's/GRUB_CMDLINE_LINUX_DEFAULT="quiet"/GRUB_CMDLINE_LINUX_DEFAULT="quiet iommu=pt"/g' /etc/default/grub
    update-grub
    ```

1. Add the kernel modules to enable vfio (virtual function io) that allows to virtualize these devices
    ```
    echo "vfio" >> /etc/modules
    echo "vfio_iommu_type1" >> /etc/modules
    echo "vfio_pci" >> /etc/modules
    echo "vfio_virqfd" >> /etc/modules
    ```

1. Then, we need to tell `vfio` which devices to virtualize (the GPU `1002:1681` + Audio `1002:1640`)
    ```
    echo "options vfio-pci ids=1002:1681,1002:1640" >> /etc/modprobe.d/vfio.conf
    ```

1. Avoid loading the GPU drivers in the host. These are the default AMD + Sound drivers, but you can find the ones your system is using by running `lspci -nnk` and checking the "Kernel driver in Use" section.
    ```
    echo "blacklist radeon" >> /etc/modprobe.d/pve-blacklist.conf
    echo "blacklist amdgpu" >> /etc/modprobe.d/pve-blacklist.conf
    echo "blacklist snd_hda_intel" >> /etc/modprobe.d/pve-blacklist.conf
    ```

1. Refresh the kernel modules and restart:
    ```
    update-initramfs -u -k all
    shutdown -r now
    ```
    
1. After the restart, validate that the `Kernel driver in Use` for these PCI devices is `vfio-pci` now, with
    ```
    lspci -nnk
    ```

## Making the GPU available to the host again after stopping the VMs (solving the AMD Reset Bug)

There is a known bug with AMD graphics cards where the host crashes after it tries to use a GPU after the passthrough. This is a mitigation effort but there isn't a real solution available for this.

3. Install the `vendor-reset` kernel module:
    ```
    apt install pve-headers-$(uname -r)
    apt install git dkms build-essential
    git clone https://github.com/gnif/vendor-reset.git
    cd vendor-reset
    dkms install .
    echo "vendor-reset" >> /etc/modules
    ```
3. Create the vendor-reset GPU re-initialization service. **Remember to update the GPU PCI ID to your own one**:
    ```
    cat << EOF >>  /etc/systemd/system/vreset.service
    [Unit]
    Description=AMD GPU reset method to 'device_specific'
    After=multi-user.target
    [Service]
    ExecStart=/usr/bin/bash -c 'echo device_specific > /sys/bus/pci/devices/0000:34:00.0/reset_method'
    [Install]
    WantedBy=multi-user.target
    EOF
    systemctl enable vreset.service && systemctl start vreset.service
    ```
3. Refresh the kernel modules and restart:
    ```
    update-initramfs -u -k all
    shutdown -r now
    ```
2. After the restart, you can check if the `vendor-reset` module was started properly with `dmesg | grep vendor_reset`. The output should be similar to:
    ```
    [    2.369873] vendor_reset: loading out-of-tree module taints kernel.
    [    2.426548] vendor_reset_hook: installed
    ```

## Creating the Windows VM

1. Via the web UI, upload a Windows 10 installation ISO image to the `local` storage.
    - Click on `local` in the left menu, then `ISO Images`, then `Upload`
1. Create the VM with the following parameters:
    - ISO Image: the one you uploaded
    - Type: Microsoft Windows
    - Version: 10/2016/2019
    - Machine: q35
    - Bios: SeaBIOS
    - Qemu Agent: ON
    - Disk: at least 64gb, Discard ON, SSD emulation ON
    - CPU Type: host
    - RAM: at least 4gb
1. Run the machine and install Windows (type of installation: custom)
2. After finishing the Windows installation, stop the VM

# Configuring the GPU in the Windows VM

In order to pass the GPU device properly, we need to tell the VM which GPU BIOS to use. Luckily for us, we can extract this from the host (proxmox) machine via SSH:

3. Create a `vbios.c` file in the host (proxmox) with the following contents:
    <details><summary>Expand `vbios.c`</summary>

    ```c
    #include <stdint.h>
    #include <stdio.h>
    #include <stdlib.h>

    typedef uint32_t ULONG;
    typedef uint8_t UCHAR;
    typedef uint16_t USHORT;

    typedef struct {
        ULONG Signature;
        ULONG TableLength; // Length
        UCHAR Revision;
        UCHAR Checksum;
        UCHAR OemId[6];
        UCHAR OemTableId[8]; // UINT64  OemTableId;
        ULONG OemRevision;
        ULONG CreatorId;
        ULONG CreatorRevision;
    } AMD_ACPI_DESCRIPTION_HEADER;

    typedef struct {
        AMD_ACPI_DESCRIPTION_HEADER SHeader;
        UCHAR TableUUID[16]; // 0x24
        ULONG VBIOSImageOffset; // 0x34. Offset to the first GOP_VBIOS_CONTENT block from the beginning of the stucture.
        ULONG Lib1ImageOffset; // 0x38. Offset to the first GOP_LIB1_CONTENT block from the beginning of the stucture.
        ULONG Reserved[4]; // 0x3C
    } UEFI_ACPI_VFCT;

    typedef struct {
        ULONG PCIBus; // 0x4C
        ULONG PCIDevice; // 0x50
        ULONG PCIFunction; // 0x54
        USHORT VendorID; // 0x58
        USHORT DeviceID; // 0x5A
        USHORT SSVID; // 0x5C
        USHORT SSID; // 0x5E
        ULONG Revision; // 0x60
        ULONG ImageLength; // 0x64
    } VFCT_IMAGE_HEADER;

    typedef struct {
        VFCT_IMAGE_HEADER VbiosHeader;
        UCHAR VbiosContent[1];
    } GOP_VBIOS_CONTENT;

    int main(int argc, char** argv)
    {
        FILE* fp_vfct;
        FILE* fp_vbios;
        UEFI_ACPI_VFCT* pvfct;
        char vbios_name[0x400];

        if (!(fp_vfct = fopen("/sys/firmware/acpi/tables/VFCT", "r"))) {
            perror(argv[0]);
            return -1;
        }

        if (!(pvfct = malloc(sizeof(UEFI_ACPI_VFCT)))) {
            perror(argv[0]);
            return -1;
        }

        if (sizeof(UEFI_ACPI_VFCT) != fread(pvfct, 1, sizeof(UEFI_ACPI_VFCT), fp_vfct)) {
            fprintf(stderr, "%s: failed to read VFCT header!\n", argv[0]);
            return -1;
        }

        ULONG offset = pvfct->VBIOSImageOffset;
        ULONG tbl_size = pvfct->SHeader.TableLength;

        if (!(pvfct = realloc(pvfct, tbl_size))) {
            perror(argv[0]);
            return -1;
        }

        if (tbl_size - sizeof(UEFI_ACPI_VFCT) != fread(pvfct + 1, 1, tbl_size - sizeof(UEFI_ACPI_VFCT), fp_vfct)) {
            fprintf(stderr, "%s: failed to read VFCT body!\n", argv[0]);
            return -1;
        }

        fclose(fp_vfct);

        while (offset < tbl_size) {
            GOP_VBIOS_CONTENT* vbios = (GOP_VBIOS_CONTENT*)((char*)pvfct + offset);
            VFCT_IMAGE_HEADER* vhdr = &vbios->VbiosHeader;

            if (!vhdr->ImageLength)
                break;

            snprintf(vbios_name, sizeof(vbios_name), "vbios_%x_%x.bin", vhdr->VendorID, vhdr->DeviceID);

            if (!(fp_vbios = fopen(vbios_name, "wb"))) {
                perror(argv[0]);
                return -1;
            }

            if (vhdr->ImageLength != fwrite(&vbios->VbiosContent, 1, vhdr->ImageLength, fp_vbios)) {
                fprintf(stderr, "%s: failed to dump vbios %x:%x\n", argv[0], vhdr->VendorID, vhdr->DeviceID);
                return -1;
            }

            fclose(fp_vbios);

            printf("dump vbios %x:%x to %s\n", vhdr->VendorID, vhdr->DeviceID, vbios_name);

            offset += sizeof(VFCT_IMAGE_HEADER);
            offset += vhdr->ImageLength;
        }

        return 0;
    }
    ```

    </details>
3. Get the `vbios` binary by compiling and running `vbios.c`:
    ```
    gcc vbios.c -o vbios
    ./vbios
    mv vbios_1002_1681.bin /usr/share/kvm/
    ```
4. In the proxmox web UI, click on the windows VM, Hardware, Add, PCI Device:
    - Raw device: pick the PCI ID that we identified on the first steps, in my case its `0000:34:00.0`
    - All Functions: OFF
    - Primary GPU: OFF
    - PCI-Express: ON
5. Do the same for the Audio device, in my case its `0000:34:00.1`
6. Set the correct BIOS for the GPU:
    - Edit `/etc/pve/qemu-server/<VM_ID>.conf`
    - Modify the `args` and `cpu` lines
    - Modify the `hostpci` line for the GPU
    ```diff
    +args: -cpu 'host,-hypervisor,kvm=off'
    agent: 1
    balloon: 2048
    bios: seabios
    boot: order=ide0;ide2;net0
    cores: 8
    -cpu: host
    +cpu: host,hidden=1,flags=+pcid
    -hostpci0: 0000:34:00.0,pcie=1
    +hostpci0: 0000:34:00.0,pcie=1,romfile=vbios_1002_1681.bin
    hostpci1: 0000:34:00.1,pcie=1
    ide0: local-lvm:vm-100-disk-0,discard=on,size=64G,ssd=1
    ide2: local:iso/Windows10.iso,media=cdrom,size=4697792K
    machine: pc-q35-8.0
    memory: 12048
    meta: creation-qemu=8.0.2,ctime=1696067822
    name: win10
    net0: e1000=E2:4A:E7:86:8D:13,bridge=vmbr0,firewall=1
    numa: 0
    ostype: win10
    scsihw: virtio-scsi-single
    sockets: 1
    ```
7. Run the VM and install [the most recent VirtIO drivers](https://pve.proxmox.com/wiki/Windows_VirtIO_Drivers) (virtio-win-guest-tools.exe).
7. Also install [the official AMD GPU drivers](https://www.amd.com/en/support/apu/amd-ryzen-processors/amd-ryzen-7-processors-radeon-graphics/amd-ryzen-7-7735hs). **Use the OFFLINE installer**, the online installer will complain that the computer is not an official AMD computer (its probably missing passthrough of some other devices in the IOMMU group, help appreciated).
7. Install https://github.com/inga-lovinde/RadeonResetBugFix service to make sure the GPU can be transferred properly to the host
   
# Using the GPU as the Primary GPU

Now that we have all the drivers ready, we can enable the GPU as the Primary GPU:
   
1. Enable Remote desktop in the VM (In Windows: Remote Desktop Settings -> Enable Remote Desktop)
8. Change the PC name to the same name as in proxmox to use it for the remote connection
8. Shut down the windows VM
0. Edit the VM Hardware again:
    - Change `display` to `none`
    - Make the GPU PCI device the `Primary GPU`
9. Start the VM again and login in to it via Remote Desktop. Alternatively, you can also plug a monitor and you should see the VM there, passthrough the USB devices for keyboard and mouse and you have a fully working virtualized PC.
   
# (optional) Getting OVMF (UEFI) BIOS working: Error 43

If you tried to follow the guide but instead of SeaBIOS you selected UEFI, you have probably encountered the famous "ERROR 43". Luckily the solution for this is quite simple: **configuring the UEFI ROM for the audio device**.
   
1. Download `AMDGopDriver.rom` from this repository.
2. Copy the file inside the proxmox machine, in `/usr/share/kvm/AMDGopDriver.rom`
3. Edit `/etc/pve/qemu-server/<VM_ID>.conf`
    - Modify the `hostpci` line for the Audio Device and append `,romfile=AMDGopDriver.rom`
    ```diff
    args: -cpu 'host,-hypervisor,kvm=off'
    agent: 1
    balloon: 2048
    bios: ovmf
    boot: order=ide0;ide2;net0
    cores: 8
    cpu: host,hidden=1,flags=+pcid
    hostpci0: 0000:34:00.0,pcie=1,romfile=vbios_1002_1681.bin
    -hostpci1: 0000:34:00.1,pcie=1
    +hostpci1: 0000:34:00.1,pcie=1,romfile=AMDGopDriver.rom
    ide0: local-lvm:vm-100-disk-0,discard=on,size=64G,ssd=1
    ide2: local:iso/Windows10.iso,media=cdrom,size=4697792K
    machine: pc-q35-8.0
    memory: 12048
    meta: creation-qemu=8.0.2,ctime=1696067822
    name: win10
    net0: e1000=E2:4A:E7:86:8D:13,bridge=vmbr0,firewall=1
    numa: 0
    ostype: win10
    scsihw: virtio-scsi-single
    sockets: 1
    ```
9. Start the VM again and login via Remote Desktop. Opening "Device Manager" should show the GPU working properly. If you still see error 43, try rebooting the host :)

# Results

![image](https://github.com/isc30/UM773-Lite-Proxmox/assets/10807051/69fea650-ab08-427a-98f3-caccc1bacd1b)
![image](https://github.com/isc30/UM773-Lite-Proxmox/assets/10807051/74c9423f-875c-4b73-b4d2-b4e742777812)
![image](https://github.com/isc30/UM773-Lite-Proxmox/assets/10807051/b06415f0-fd4b-488f-9ac7-88c3ad0af6e8)

# Known issues

- ## When entering via Remote Desktop, the GPU is disabled
  I'm unsure why this happens, but it seems like right-click + Enable Device makes it work again

- ## In random situations, I still get "error 43" when trying to initialize the GPU in the VM
  Probably related to the "amd reset issue", that prevents the GPU from binding to a VM after it was used once. The only "real" solution for this is to restart the proxmox host after stopping a VM that used the GPU. :sad:
