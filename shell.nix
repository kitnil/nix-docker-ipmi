with import <nixpkgs> {};

stdenv.mkDerivation {
  name = "ipmishell";
  buildInputs = [
   (callPackage ./default.nix { })
  ];
}
