with import <nixpkgs> { };

with lib;

let
  flattenSetSep = sep: set:
    listToAttrs (collect (x: x ? name) (mapAttrsRecursive
      (p: v: attrsets.nameValuePair (builtins.concatStringsSep sep p) v) set));
  flattenSet = set: flattenSetSep "." set;
  ipmi = callPackage ./default.nix {};
  entrypoint = (stdenv.mkDerivation {
    name = "ipmi";
    builder = writeScript "builder.sh" (''
      source $stdenv/setup
      mkdir -p $out/bin

      cat > $out/bin/ipmi <<'EOF'
      #!${bash}/bin/bash
      # Generate $HOME/.java/deployment/deployment.properties
      timeout 1 ${ipmi}/bin/ControlPanel

      # Disable signed self-certificate error
      cat >> $HOME/.java/deployment/deployment.properties << 'EOFF'
      deployment.security.level=MEDIUM
      EOFF

      # Create a wrapper
      IPMI_HOST=$2 IPMI_OUTPUT=/tmp/$IPMI_HOST.jviewer.jnlp \
      IPMI_USER=ADMIN IPMI_PASSWORD=$1                      \
      ${ipmi}/bin/ipmi $1 $2
      EOF

      chmod 555 $out/bin/ipmi
      ln -s ${ipmi}/bin/ControlPanel $out/bin/ControlPanel
    '');
    });
in pkgs.dockerTools.buildLayeredImage rec {
  name = "docker-registry.intr/utils/nix-ipmi";
  tag = "latest";
  contents = [
    bashInteractive coreutils fontconfig.out shared_mime_info
  ];
  config = {
    Entrypoint = [ "${entrypoint}/bin/ipmi" ];
    Env = [
      "TZ=Europe/Moscow"
      "TZDIR=${tzdata}/share/zoneinfo"
      "LOCALE_ARCHIVE_2_27=${locale}/lib/locale/locale-archive"
      "LOCALE_ARCHIVE=${locale}/lib/locale/locale-archive"
      "LC_ALL=en_US.UTF-8"
    ];
    Labels = flattenSet rec {
      ru.majordomo.docker.cmd =
        builtins.concatStringsSep " " [
          "xhost" "+local:;"
          "docker" "run" "--rm" "--network=host" "--tty" "--interactive"
          "--user" "1000:997" "--env" "DISPLAY=$DISPLAY"
          "--volume" "/etc/localtime:/etc/localtime:ro"
          "--volume" "/tmp/.X11-unix:/tmp/.X11-unix"
          "${name}:master" "IPMI_PASSWORD" "jenkins.ipmi"
        ];
    };
  };
  extraCommands = ''
    set -x -e

    mkdir -p {etc,home/alice,root,tmp}
    chmod 755 etc
    chmod 777 home/alice
    chmod 1777 tmp

    cat > etc/passwd << 'EOF'
    root:!:0:0:System administrator:/root:/bin/sh
    alice:!:1000:997:Alice:/home/alice:/bin/sh
    EOF

    cat > etc/group << 'EOF'
    root:!:0:
    users:!:997:
    EOF
  '';
}
