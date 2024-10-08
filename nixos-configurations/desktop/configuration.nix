{ diskoConfigurations, inputs, ... }:
{
  networking.hostName = "desktop";
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
    diskoConfigurations.desktop
    inputs.nixos-hardware.common-cpu-intel
    inputs.nixos-hardware.common-gpu-intel
    inputs.nixos-hardware.common-pc-ssd
    inputs.nixos-hardware.common-hidpi
  ];
}
