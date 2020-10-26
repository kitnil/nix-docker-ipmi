with import <nixpkgs> {};

let
  ipmi = (callPackage ./default.nix { });
in stdenv.mkDerivation {
  name = "ipmishell";
  buildInputs = [ coreutils dnsutils gawk ipmi ];
  shellHook = ''
    source ${ipmi}/share/bash-completion/completions/ipmi
  '';
}
