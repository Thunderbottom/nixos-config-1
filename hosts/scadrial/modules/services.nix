{ pkgs, lib, ... }:
{
  services.znapzend = {
    enable = true;
    pure = true;
    zetup = {
      "apool/ROOT/system" = {
        timestampFormat = "%Y-%m-%dT%H%M%S";
        plan = "15min=>5min,4h=>15min,1d=>4h,1w=>1d,1m=>1w,1y=>1m";
        recursive = true;
      };
      "apool/ROOT/user" = {
        timestampFormat = "%Y-%m-%dT%H%M%S";
        plan = "15min=>5min,4h=>15min,1d=>4h,1w=>1d,1m=>1w,1y=>1m";
        recursive = true;
      };
      # TODO: zrepl to 14tb external drive
      "rpool/win10" = {
        timestampFormat = "%Y-%m-%dT%H%M%S";
        plan = "1w=>1d";
      };
    };
  };

  # Scrub the disk regularly to ensure integrity
  services.zfs.autoScrub.enable = true;
  services.zfs.autoScrub.interval = "weekly";

  # Automount USB
  services.gvfs.enable = true;

  # Hide the "help" message
  # services.mingetty.helpLine = lib.mkForce "";

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;
  services.openssh.passwordAuthentication = false;

  # Enable CUPS to print documents.
  services.printing = {
    enable = true;
    drivers = with pkgs; [ gutenprint ];
  };

  # Necessary for discovering network printers.
  services.avahi = {
    enable = true;
    nssmdns = true;
  };

  # services.udev.packages for packages with udev rules
  # SUBSYSTEMS=="usb", ATTRS{idVendor}=="04d8", ATTRS{idProduct}=="eed2", TAG+="uaccess", RUN{builtin}+="uaccess"
  services.udev.extraRules =
    # Set noop scheduler for zfs partitions
    ''
      KERNEL=="sd[a-z]*[0-9]*|mmcblk[0-9]*p[0-9]*|nvme[0-9]*n[0-9]*p[0-9]*", ENV{ID_FS_TYPE}=="zfs_member", ATTR{../queue/scheduler}="none"
    '' +
    # YMDK NP21 bootloader permissions (obdev HIDBoot)
    ''
      SUBSYSTEMS=="usb", ATTRS{idVendor}=="16c0", ATTRS{idProduct}=="05df", TAG+="uaccess", RUN{builtin}+="uaccess"
    '';
}
