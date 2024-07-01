{ pkgs ? import <nixpkgs> { inherit overlays; }
, overlays ? [ (import ../default.nix) ], mkShell ? pkgs.mkShell }:

mkShell { packages = [ pkgs.cpython."3.7.3" ]; }
