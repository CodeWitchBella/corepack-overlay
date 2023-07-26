# corepack-overlay

Overlay for installing yarn and pnpm via corepack powered by `packageManager` field in your `package.json`.

## Example flake

```nix
{
  description = "Example flake";

  inputs = {
    nixpkgs.url      = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url  = "github:numtide/flake-utils";
    corepack-overlay = {
      url = "github:CodeWitchBella/corepack-overlay/main";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, corepack-overlay, flake-utils, ... }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        overlays = [ (import corepack-overlay ./package.json) ];
        pkgs = import nixpkgs {
          inherit system overlays;
        };
      in
      {
        packages.default = pkgs.corepack;
        devShells.default = pkgs.mkShell {
          buildInputs = [
            pkgs.corepack
            pkgs.nodejs
          ];
        };
      }
    );
}
```