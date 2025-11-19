---
title: "Installing Arch on a Dell Precision 5530"
date: 2023-08-02T14:25:55Z
modified: 2023-11-22
tags:
  - Arch Linux
---

I recently installed Arch on my laptop, and while it went about as smoothly as a
fresh OS install can go, there were a few footguns I ran into that I wanted to
document.

<!--more-->

## Preparation

If there is wiki information about the specific hardware you are installing Arch
on like there is for the [Precision laptops][arch-precision], it's a good idea
to read that first.

## Installation

_Following the [Arch install guide][arch-install-guide] will get you to a
working install. Eventually._

I missed a few crucial steps in the guide that are particularly important if you
don't want to keep having to boot into the live install. Reading all the words
is helpful. Yes, even the small ones.

### Disk Partitioning

The install guide gives a quick mention that you should use `fdisk` to create
the partitions for your install. I was not super familiar with `fdisk`, so I
needed a little bit more instruction. I ended up with three partitions for my
single-OS install that I created with `fdisk /dev/nvme0n1`:

1. **EFI System** - Starting at the lowest sector available, ending at `+512M`,
   and with a type of `EFI System`
2. **Swap** - Starting at the next available sector, ending at `+4G`, and with a
   type of `Linux swap`
3. **Root** - Starting at the next available sector, ending at the last sector
   available, and with the default type of `Linux filesystem`

In my case, these were `/dev/nvme0n1p{1,2,3}`, respectively. I then created the
appropriate filesystems with:

```shell
mkfs.fat -F 32 /dev/nvme0n1p1
mkswap /dev/nvme0n1p2
mkfs.ext4 /dev/nvme0n1p3
```

### Network Management

The installation guide leads you through connecting to the internet as one of
the first steps. It is important to note that this does not carry over into the
freshly installed system. Once you chroot into the new system, ensure you
install a [network manager][arch-network-managers]. I went with `NetworkManager`
because I knew it worked with the GNOME desktop environment I installed. Make
sure it starts at boot with:

```shell
systemctl enable NetworkManager
```

### Boot Loader

There are two very important lines in the install guide that talk about
installing a boot loader. As I found out, if you manage to miss these two lines,
your laptop will boot straight to Dell's recovery software.

Also remember that if you're installing GRUB, you can't just install it and call
it a day. You also have to generate the config with `grub-mkconfig`, or else you
will boot straight to the GRUB shell.

### Desktop Environment

I chose to use GNOME for my desktop environment. So far it works perfectly out
of the box with proper display scaling and everything. In my opinion, the goal
of the inital install is to get to a functional desktop environment connected to
the internet as a normal user with admin privileges through `sudo`. The basic
steps for this were to install all the software:

```shell
# I just accepted all the default suggestions
pacman -S gnome sudo
```

then create your normal user and set a password:

```shell
useradd -mG wheel my-username
passwd my-username
```

then make sure that user has admin access by enabling access for the `wheel`
group with `visudo`. Finally, enable the desktop service:

```shell
systemctl enable gdm
```

After a restart, you should be able to log in to the desktop environment as a
normal user, and have `sudo` privileges to continue configuring the system.

## Thunderbolt

In order to get USB ports working on my Thunderbolt dock, I had to edit the BIOS
setting for Thunderbolt enumeration to "Native", and I had to add the following
kernel parameters as described in [this post][caldigit-ts4-arch]:

```
pci=assign-busses,hpbussize=0x33,realloc,hpmemsize=512M nvme.noacpi=1
```

Without these changes, displays were working, but the USB ports on the dock were
not functional.

[arch-install-guide]: https://wiki.archlinux.org/title/Installation_guide
[arch-network-managers]:
  https://wiki.archlinux.org/title/Network_configuration#Network_managers
[arch-precision]: https://wiki.archlinux.org/title/Laptop/Dell#Precision
[caldigit-ts4-arch]:
  https://community.frame.work/t/arch-caldigit-ts4-dock-xfce4-trials-tribulations-and-fixes/29117
