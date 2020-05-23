# dotfiles

### Hostnames

I'm a big fan of [Brandon Sanderson], so that's where all of my hostnames come
from (see [`hostnames`](./hostnames)). They were manually copy-pasted from throughout the
[Coppermind] wiki and are [planets, shards], general terms, worldhoppers, and
[locations] throughout his works. Any of these that had a space or apostrophe
were discarded.

[Brandon Sanderson]: https://www.brandonsanderson.com/
[hostnames]: ./hostnames
[Coppermind]: https://coppermind.net/wiki/Coppermind:Welcome
[planets, shards]: https://coppermind.net/wiki/Cosmere#Planets
[locations]: https://coppermind.net/wiki/Category:Locations

---

# Setup stuff

https://grahamc.com/blog/nixos-on-zfs
https://elis.nu/blog/2020/05/nixos-tmpfs-as-root/

## 1. partition
  - 512MiB /boot at the beginning
  - 16GiB swap partition at the beginning
  - rest "linux partition" (for ZFS) -- don't forget native encryption
    ("encryption=on") and "compression=on"
    - tank/system (none) -- should be backed up
    - tank/system/root (legacy)
    - tank/system/var (legacy)
    - tank/local (none) -- shouldn't be backed up
    - tank/local/nix (legacy)
    - tank/user (none) -- should be backed up
    - tank/user/home (legacy)

export DISK=/dev/disk/by-id/.....
gdisk $DISK
  - o (delete all partitions + protective mbr)
  - n, 1, +1M, +512M, ef00  (EFI boot)
  - n, 2, ...,  +16G, 8200  (swap)
  - n, 3, ...,   ...,  ...  (Linux)
  - w

mkfs.fat -F 32 -n boot $DISK-part1
mkswap -L swap $DISK-part2

zpool create \
    -O atime=off \
    -O compression=on \
    -O encryption=on -O keyformat=passphrase \
    -O xattr=sa \
    -O acltype=posixacl \
    -O mountpoint=none \
    -R /mnt \
    tank $DISK-part3

zfs create -o mountpoint=none -o canmount=off tank/system
zfs create -o mountpoint=legacy tank/system/root
zfs create -o mountpoint=legacy tank/system/var
zfs create -o mountpoint=none -o canmount=off tank/local
zfs create -o mountpoint=legacy tank/local/nix
zfs create -o mountpoint=none -o canmount=off tank/user
zfs create -o mountpoint=legacy tank/user/home

mount -t zfs tank/system/root /mnt
mkdir -p /mnt/var /mnt/nix /mnt/home /mnt/boot
mount -t zfs tank/system/var /mnt/var
mount -t zfs tank/local/nix /mnt/nix
mount -t zfs tank/user/home /mnt/home
mount $DISK-part1 /mnt/boot

## 2. install
git clone https://github.com/cole-h/nixos-config /mnt/tmp/nixos-config

nixos-generate-config --root /mnt --dir /tmp/nixos-config/nixops/scadrial

export NIXOS_CONFIG=/mnt/tmp/nixos-config/nixops/scadrial/configuration.nix

nixos-install

set up gpg key -- probably also need to link in sshcontrol, probably

git clone git@github.com:cole-h/nix-secrets /mnt/tmp/dotfiles/secrets

rsync -a /mnt/tmp/dotfiles /home/vin/.config/nixpkgs

nix run nixpkgs.nixops -c nixops ssh vin@scadrial '
    git clone https://github.com/rycee/home-manager $HOME/workspace/vcs/home-manager
    git clone https://github.com/alacritty/alacritty $HOME/workspace/vcs/alacritty
    git clone https://github.com/ajeetdsouza/zoxide $HOME/workspace/vcs/zoxide
    nix-shell $HOME/workspace/vcs/home-manager -A install'

