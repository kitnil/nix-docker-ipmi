{
  description = "Bash script to connect to servers with IPMI support";

  inputs = {
    nixpkgs-unstable.url = "nixpkgs/nixpkgs-unstable";
    flake-compat = {
      url = "github:edolstra/flake-compat";
      flake = false;
    };

    nixpkgs = { url = "nixpkgs/19.09"; flake = false; };
    nixpkgs-15-09 = { url = "nixpkgs/15.09"; flake = false; };
  };

  outputs = { self, nixpkgs, nixpkgs-unstable, nixpkgs-15-09, ... }:
    let
      pkgs-unstable = import nixpkgs-unstable { inherit system; };

      system = "x86_64-linux";
      pkgs = import nixpkgs { inherit system; };
      inherit (pkgs) callPackage;
      inherit (pkgs) lib;

      pkgs-15-09 = import nixpkgs-15-09 {
        inherit system;
        config = { allowUnfree = true; };
      };
    in {
      packages.${system} = {
        inherit (pkgs-15-09) icedtea7_web;
        ipmi = pkgs.callPackage ./. {
          inherit (self.packages.${system}) icedtea7_web;
        };
      };

      defaultPackage.x86_64-linux = self.packages.${system}.ipmi;

      devShell.${system} = pkgs-unstable.mkShell {
        buildInputs = [ pkgs-unstable.nixUnstable ];
      };
    };
}
