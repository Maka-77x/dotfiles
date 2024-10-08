{
  lib,
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
    util-linux
    intel_gpu_top
    smartctl
    nvme-cli
    lscpu
    cpupower
    turbostat
    dmidecode
    inxi
    ethtool
    iw
    iwconfig
    smartctl
    glxinfo
    vainfo
    ly
    tput
    mcookie
    ncurses-bin

  ];
  nix = {
    settings = {
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
  boot = {
    kernelPackages = pkgs.linuxKernel.packages.linux_xanmod_latest;
    loader = {
      grub = {
        device = "nodev";
        efiSupport = true;
      };
      efi.canTouchEfiVariables = true;
    };
    kernelParams = [
      "i915.force_probe=46a8"
      "i915.enable_psr=1"
    ];
    # Enable KVM nested virtualization
    extraModprobeConfig = "options kvm_intel nested=1";
  };

  networking.networkmanager.enable = true;

  time.timeZone = "Europe/London";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_GB.UTF-8";
  # use xkbOptions in tty.
  console.useXkbConfig = true;

  hardware = {
    firmware.intelWifiFIrmware = true;
    # Enable QMK support
    keyboard.qmk.enable = false;
    # Enable AMD microcode updates
    enableRedistributableFirmware = true;
    opengl = {
      enable = true;
      extraPackages = with pkgs; [
        vulkan-loader
        intel-media-driver
        intel-graphics-compiler
        vpl-gpu-rt
      ];
    };
  };

  # Enable ssh agent
  programs.ssh.startAgent = true;
  # programs.lm_sensor.enable = true;

  powerManagement.enable = true;

  # List services that you want to enable:
  services = {
    tlp.enable = true;
    fstrim.enable = true;
    # bolt.enable = true;
    # iwd.enable = true;
    xserver = {
      enable = true;
      videoDrivers = [
        "modesetting"
        "intel"
      ];
      useGlamor = true;
    };
    # Enable CUPS to print documents.
    printing.enable = true;
    # Required for udiskie
    udisks2.enable = true;
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "24.05"; # Did you read the comment?
}
