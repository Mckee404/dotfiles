#!/usr/bin/env bash
# Point /etc/nixos at this checkout, preserving the previous configuration.
set -euo pipefail

if (( $# != 0 )); then
  echo "Usage: sudo bash $0" >&2
  exit 2
fi

repo_dir="$(dirname -- "$(realpath -- "${BASH_SOURCE[0]}")")"
target=/etc/nixos

if [[ ! -f "$repo_dir/flake.nix" || ! -f "$repo_dir/flake.lock" || ! -f "$repo_dir/nix/nixos/configuration.nix" ]]; then
  echo "Missing NixOS configuration in $repo_dir" >&2
  exit 1
fi

if [[ -L "$target" && "$(readlink -f -- "$target")" == "$repo_dir" ]]; then
  echo "$target already points to $repo_dir"
  exit 0
fi

if (( EUID != 0 )); then
  echo "Run with sudo: sudo bash \"$repo_dir/install-nixos.sh\"" >&2
  exit 1
fi

backup=''
if [[ -e "$target" || -L "$target" ]]; then
  backup="$(mktemp -d /etc/nixos.backup-XXXXXXXX)"
  mv -T -- "$target" "$backup/nixos"
  echo "Previous configuration: $backup/nixos"
fi

if ! ln -sT -- "$repo_dir" "$target"; then
  if [[ -n "$backup" ]]; then
    mv -T -- "$backup/nixos" "$target"
    rmdir -- "$backup"
  fi
  exit 1
fi

printf '%s -> %s\n' "$target" "$(readlink -f -- "$target")"
echo 'Apply configuration: sudo nixos-rebuild switch --flake /etc/nixos#nixos'
