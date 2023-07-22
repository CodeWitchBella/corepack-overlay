{
  description = "A devShell example";

  inputs = {
    nixpkgs.url      = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url  = "github:numtide/flake-utils";
    corepack-overlay = {
        # replace this with github:CodeWitchBella/corepack-overlay when used outside of this repo
        url = "../..";
        inputs.nixpkgs.follows = "nixpkgs";
        inputs.flake-utils.follows = "flake-utils";
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
      with pkgs;
      {
        packages.default = pkgs.corepack;
        devShells.default = mkShell {
          buildInputs = [
            pkgs.corepack
            pkgs.nodejs
          ];
          shellHook =
          ''
            echo "Hello shell"
            export COREPACK_ENABLE_NETWORK=0
            export COREPACK_HOME=${pkgs.corepack.home}
          '';
        };
      }
    );
}