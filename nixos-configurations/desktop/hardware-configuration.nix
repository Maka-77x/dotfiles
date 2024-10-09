# Do not modify this file!  It was generated by ‘nixos-generate-config’
# and may be overwritten by future invocations.  Please make changes
# to /etc/nixos/configuration.nix instead.
{
  config,
  lib,
  pkgs,
  modulesPath,
  ...
}:
{
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
  ];

  boot.loader = {
    systemd-boot.enable = true;
  };
  boot.loader = {
    efi.canTouchEfiVariables = true;
  };

  boot.blacklistedKernelModules = [
    "nouveau"
    "nvidia"
  ];
  boot.extraModulePackages = [ ];

  boot.initrd = {
    availableKernelModules = [
      "xhci_pci"
      "thunderbolt"
      "nvme"
      "usb_storage"
      "usbhid"
      "sd_mod"
      "i915"
      # "ahci"
    ];
    kernelModules = [
      "dm-snapshot"
      "nvme"
    ];
    systemd.enable = true;
  };
  boot.kernelModules = [
    "kvm-intel"
    "i915"
    # "acpi_ec"
    # "ec_sys"
    # ""
  ];
  boot.kernelParams = [
    "i915.force_probe=46a8"
    "i915.force_probe=4628"
    "i915.enable_psr=1"
    "i915.enable_guc=3"
    "ibt=off" # otherwise VirtualBox breaks?
    "intel_pstate=active"
    "acpi_rev_override=5" # https://forum.endeavouros.com/t/how-to-choose-the-proper-acpi-kernel-argument/6172/5

  ];

  boot.loader.grub = {
    device = "nodev";
    efiSupport = true;
  };

  # Enables DHCP on each ethernet and wireless interface. In case of scripted networking
  # (the default) this is the recommended approach. When using systemd-networkd it's
  # still possible to use this option, but it's recommended to use it in conjunction
  # with explicit per-interface declarations with `networking.interfaces.<interface>.useDHCP`.
  networking.useDHCP = lib.mkDefault true;
  # networking.interfaces.enp0s31f6.useDHCP = lib.mkDefault true;
  # networking.interfaces.wlp0s20f3.useDHCP = lib.mkDefault true;

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";

  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
  hardware.firmware = with pkgs; [ firmwareLinuxNonfree ];
  hardware.enableAllFirmware = true;

  hardware.graphics = {
    enable = lib.mkDefault true;
    enable32Bit = lib.mkDefault true;
    extraPackages = with pkgs; [
      intel-media-driver
      ocl-icd
      intel-ocl
      linux-firmware
      mesa
      # vaapi-intel-hybrid
      # vaapiIntel
      # vaapiVdpau
      vpl-gpu-rt
      # intel-vaapi-driver
      # intel-media-driver
      # libvdpau-va-gl
      # vpl-gpu-rt
      # mesa
      # intel-gpu-tools
      intel-compute-runtime
      # intel-graphics-compiler
      # vulkan-loader
    ];
    extraPackages32 = with pkgs.driversi686Linux; [
      intel-media-driver
      # intel-ocl
      # linux-firmware
      mesa
      # vaapi-intel-hybrid
      # vaapiIntel
      # vaapiVdpau
      # vpl-gpu-rt
      # intel-vaapi-driver
      # intel-media-driver
      # libvdpau-va-gl
    ];
  };
  # hardware.e
}
