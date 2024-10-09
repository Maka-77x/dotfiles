{
  lib,
  config,
  pkgs,
  inputs,
  ...
}:
{
  # Import all nix files in directory 
  # Should ignore this file and all non-nix files
  imports =
    map (file: ./. + "/${file}") (
      lib.strings.filter (file: lib.strings.hasSuffix ".nix" file && file != "default.nix") (
        builtins.attrNames (builtins.readDir ./.)
      )
    )
    ++ [
      inputs.lix-module.nixosModules.default
      inputs.disko.nixosModules.disko
      inputs.home-manager.nixosModules.home-manager
      inputs.impermanence.nixosModules.impermanence
      inputs.stylix.nixosModules.stylix
      inputs.catppuccin.nixosModules.catppuccin
      inputs.nix-gaming.nixosModules.pipewireLowLatency
      inputs.spicetify-nix.nixosModules.spicetify
    ];
  environment.systemPackages = with pkgs; [
    sof-firmware
    util-linux
    # intel_gpu_top
    # smartctl
    nvme-cli
    # lscpu
    # cpupower
    # turbostat
    dmidecode
    inxi
    ethtool
    # iw
    # iwconfig
    # smartctl
    glxinfo
    # vainfo
    # ly
    # tput
    # mcookie
    # ncurses-bin

  ];
  nix = {
    settings = {
      system-features = [
        "gccarch-x86-64-v3"
        "alderlake"
        "kvm"
        "nixos-test"
        "big-parallel"
      ];
      experimental-features = [
        "nix-command"
        "flakes"
      ];
      auto-optimise-store = true;
      repl-overlays = [ ../repl-overlay.nix ]; # Lix-specific setting
    };
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 14d";
    };
    # Set system registry to flake inputs
    registry = lib.pipe inputs [
      # Remove non flake inputs, which cause errors
      # Flakes have an attribute _type, which equals "flake"
      # while non-flakes lack this attribute
      (lib.filterAttrs (_: flake: lib.attrsets.hasAttr "_type" flake))
      (lib.mapAttrs (_: flake: { inherit flake; }))
    ];
    # For some reason, lix needs this to replace the nix command
    package = pkgs.lix;
  };

  nixpkgs = {
    overlays = [
      # custom overlay
      (import ../pkgs)
      # Hyprland community tools
      inputs.hyprland-contrib.overlays.default
    ];
    config.allowUnfree = true;
  };

  # Use GRUB
  boot.kernelPackages = pkgs.linuxKernel.packages.linux_xanmod_latest;
  # boot.loader = {
  #   grub = {
  #     device = "nodev";
  #     efiSupport = true;
  #   };
  #   efi.canTouchEfiVariables = true;
  # };
  # boot.kernelParams = [
  #   "i915.force_probe=46a8"
  #   "i915.enable_psr=1"
  #   "i915.enable_guc2"
  #   "ibt=off" # otherwise VirtualBox breaks?
  # ];
  # Enable KVM nested virtualization
  boot.extraModprobeConfig = ''
    options i915 enable_guc=3 enable_fbc=1 enable_dc=0 enable_pcr=0 enable rc6=1
  '';

  networking.networkmanager.enable = true;

  time.timeZone = "Europe/London";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_GB.UTF-8";
  # use xkbOptions in tty.
  console.useXkbConfig = true;

  hardware = {
    cpu.intel.updateMicrocode = lib.mbkDefault true;
    intel-gpu-tools.enable = lib.mkDefault true;
    # graphics = {
    #   enable = lib.mkDefault true;
    #   enable32Bit = lib.mkDefault true;
    #   extraPackages = with pkgs; [
    #     intel-vaapi-driver
    #     intel-media-driver
    #     libvdpau-va-gl
    #   ];
    #   extraPackages32 = with pkgs.driversi686Linux; [
    #     intel-vaapi-driver
    #     intel-media-driver
    #     libvdpau-va-gl
    #   ];
    # };
    # driSupport = true;
    # driSupport32bit = true;
    # firmware.intelWifiFIrmware = true;
    # Enable QMK support
    keyboard.qmk.enable = false;
    # Enable AMD microcode updates
    enableRedistributableFirmware = true;
    opengl = {
      driSupport = true;
      enable = true;
      extraPackages = with pkgs; [
        vulkan-loader
        intel-media-driver
        intel-graphics-compiler
        intel-compute-runtime
        vpl-gpu-rt
        pkgs.mesa.drivers
        intel-gpu-tools
      ];
    };
  };

  # Enable ssh agent
  programs.ssh.startAgent = true;
  # programs.lm_sensor.enable = true;

  powerManagement.enable = true;

  # List services that you want to enable:
  #Power Optimization
  boot.kernel.sysctl."vm.dirty_writeback_centisecs" = 1500; # 15 seconds

  #Power Settings
  services.power-profiles-daemon.enable = false;
  services.tlp = {
    enable = true;
    settings = {
      CPU_BOOST_ON_BAT = "0";
      SATA_LINKPWR_ON_AC = "med_power_with_dipm";
      SATA_LINKPWR_ON_BAT = "min_power";
      PCIE_ASPM_ON_AC = "default";
      PCIE_ASPM_ON_BAT = "powersave";
      WIFI_PWR_ON_AC = "off";
      WIFI_PWR_ON_BAT = "on";
      RUNTIME_PM_ON_AC = "on";
      RUNTIME_PM_ON_BAT = "auto";
      CPU_SCALING_GOVERNOR_ON_AC = "performance";
      CPU_SCALING_GOVERNOR_ON_BAT = "powersave";
      ENERGY_PERFORMANCE_PREFERENCE_ON_BAT = "power";
      CPU_ENERGY_PERF_POLICY_ON_BAT = "power";
    };
  };
  services.undervolt = {
    enable = true;
    tempBat = -25;
    #    package = pkgs.intel-undervolt;
    #    coreOffset = -1;
    #    cacheOffset = -1;
    #    gpuOffset = -100;
  };
  services.fstrim.enable = true;
  services.fprintd = {
    enable = true;
  };
  # bolt.enable = true;
  # iwd.enable = true;
  services.xserver = {
    enable = true;
    videoDrivers = [
      "modsetting"
      # "intel"
    ];
    deviceSection = ''
      Option "DRI" "3"
    '';
    # useGlamor = true;
  };
  # Enable CUPS to print documents.
  services.printing.enable = true;
  # Required for udiskie
  services.udisks2.enable = true;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "24.05"; # Did you read the comment?
}
