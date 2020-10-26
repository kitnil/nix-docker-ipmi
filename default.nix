{ stdenv, commit ? "86062d7a952c9e8cdb0b370cedf1b010e0864bb4", bash
, glibcLocales, coreutils, curl, gnugrep, gnused, gawk, adoptopenjdk-icedtea-web
, shellcheck, writeScript, buildFHSUserEnv, ipmitool, iputils, installShellFiles
}:

let
  mj-adoptopenjdk-icedtea-web7 = (import (builtins.fetchTarball {
    url = "https://github.com/nixos/nixpkgs/archive/${commit}.tar.gz";
  }) { config = { allowUnfree = true; }; }).icedtea7_web;
  mj-adoptopenjdk-icedtea-web8-javaws = buildFHSUserEnv {
    name = "mj-adoptopenjdk-icedtea-web8-hfs";
    targetPkgs = pkgs: with pkgs; [ adoptopenjdk-icedtea-web ];
    runScript = "${adoptopenjdk-icedtea-web}/bin/javaws";
  };

in stdenv.mkDerivation rec {
  pname = "ipmi";
  version = "1.0.0";
  src = ./.;
  doCheck = true;
  nativeBuildInputs = [ installShellFiles ];
  checkInputs = [ shellcheck ];
  checkPhase = ''
    shellcheck ipmi.sh
  '';
  buildPhase = ''
    export bash=${bash}
    export curl=${curl}
    export coreutils=${coreutils}
    export gawk=${gawk}
    export gnused=${gnused}
    export gnugrep=${gnugrep}
    export ipmitool=${ipmitool}
    export adoptopenjdkIcedteaWeb=${adoptopenjdk-icedtea-web}
    export mjAdoptopenjdkIcedteaWeb7=${mj-adoptopenjdk-icedtea-web7}
    export mjAdoptopenjdkIcedteaWeb8Javaws=${mj-adoptopenjdk-icedtea-web8-javaws}
    export glibcLocales=${glibcLocales}
    substituteAllInPlace ipmi.sh
    patchShebangs ipmi.sh
  '';
  installPhase = ''
    install -Dm555 ./ipmi.sh $out/bin/ipmi
    installShellCompletion --bash --name ipmi ${src}/etc/completion/bash/ipmi
  '';
}
