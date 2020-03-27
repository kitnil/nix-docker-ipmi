{ stdenv, commit ? "86062d7a952c9e8cdb0b370cedf1b010e0864bb4",
  bash, glibcLocales, coreutils, curl, gnugrep, gnused, writeScript }:

let
  mj-adoptopenjdk-icedtea-web7 = (import (builtins.fetchTarball {
    url =
      "https://github.com/nixos/nixpkgs/archive/${commit}.tar.gz";
  }) { config = { allowUnfree = true; }; }).oraclejdk7;

in stdenv.mkDerivation rec {
  name = "ipmi";
  builder = writeScript "builder.sh" (''
    source $stdenv/setup
    mkdir -p $out/bin

    ln -s ${mj-adoptopenjdk-icedtea-web7}/bin/javaws $out/bin/javaws

    cat > $out/bin/ipmi <<'EOF'
    #!${bash}/bin/bash
    HOST=$IPMI_HOST
    COOKIE=$(${curl}/bin/curl \
      --data "WEBVAR_USERNAME=$IPMI_USER&WEBVAR_PASSWORD=$IPMI_PASSWORD" \
      http://$HOST/rpc/WEBSES/create.asp \
        | ${gnugrep}/bin/grep SESSION_COOKIE \
        | ${coreutils}/bin/cut -d\' -f 4)

    ${curl}/bin/curl --cookie Cookie=SessionCookie=$COOKIE \
      http://$HOST/Java/jviewer.jnlp --output $IPMI_OUTPUT

    LANG=${glibcLocales}/lib/locale/locale-archive
    exec -a javaws ${mj-adoptopenjdk-icedtea-web7}/bin/javaws \
      -Xnosplash -wait -verbose $IPMI_OUTPUT
    EOF
    chmod 555 $out/bin/ipmi

    cat > $out/bin/ControlPanel <<'EOF'
    #!${bash}/bin/bash
    LANG=${glibcLocales}/lib/locale/locale-archive
    PATH=${gnused}/bin:$PATH
    exec -a ControlPanel ${mj-adoptopenjdk-icedtea-web7}/bin/ControlPanel "$@"
    EOF
    chmod 555 $out/bin/ControlPanel
  '');
}
