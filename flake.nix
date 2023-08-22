{
  description = ''Overlay for loading correct package manager using corepack'';

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
  };

  outputs = { self, nixpkgs }: let
    overlay = import ./.;
  in {
    overlays = {
      default = overlay;
      corepack-overlay = overlay;
    };
  };
}
