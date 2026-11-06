{ config, lib, pkgs, ... }:

{
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  wsl.defaultUser = "nixos";

  # Allow firmware upload and serial monitoring without root.
  users.users.nixos.extraGroups = [ "dialout" ];
}
