{ config, lib, pkgs, inputs, ... }:

let
  nvimDotfilesDir = "/home/nixos/dotfiles/nvim";
  nvimConfigDir = "${config.xdg.configHome}/nvim";
in

{
  home.stateVersion = "25.11";

  home.packages = with pkgs; [
    gh
    inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}.codex
  ];

  home.sessionVariables = {
    UV_PYTHON_DOWNLOADS = "never";
  };

  programs.git.enable = true;

  programs.bash = {
    enable = true;
    initExtra = ''
      . "${config.home.profileDirectory}/etc/profile.d/hm-session-vars.sh"
    '';
  };

  programs.neovim.enable = true;

  home.activation.linkNvimConfig = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    if [ -L "${nvimConfigDir}" ]; then
      ln -sfn "${nvimDotfilesDir}" "${nvimConfigDir}"
    elif [ ! -e "${nvimConfigDir}" ]; then
      ln -s "${nvimDotfilesDir}" "${nvimConfigDir}"
    else
      echo "Refusing to replace non-symlink ${nvimConfigDir}" >&2
      exit 1
    fi
  '';
}
