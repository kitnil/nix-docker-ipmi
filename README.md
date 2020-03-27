# Nix IPMI

This project provides a Nix expression to build Bash script to connect
to servers with IPMI support.

## Prerequisites

Before you begin, ensure you have met the following requirements:

* You have installed either Nix, NixOS, Docker
* You received IPMI credentials

## Installing Nix IPMI

To install IPMI Sciprt, follow these steps:

### With Docker installed

Install Majordomo certificate as described in
https://gitlab.intr/utils/nix-docker-firefox-esr/

Then clone the container and look launch command:

``` shell
sudo docker pull docker-registry.intr/utils/nix-ipmi:master
sudo docker inspect docker-registry.intr/utils/nix-ipmi:master | grep cmd
```

make sure `xhost` is installed on your system and run the container, e.g.:
``` shell
xhost +local:; docker run --rm --network=host --tty --interactive --user 1000:997 --env DISPLAY=$DISPLAY --volume /etc/localtime:/etc/localtime:ro --volume /tmp/.X11-unix:/tmp/.X11-unix docker-registry.intr/utils/nix-ipmi:master IPMI_PASSWORD jenkins.ipmi
```
NOTE: Replace `IPMI_PASSWORD`.

### With Nix installed

Add an overlay as you prefer, for example:
``` nix
with import <nixpkgs> {
  overlays = [
    (self: super: {
      ipmi = (super.callPackage (builtins.fetchGit {
        url = "https://gitlab.intr/utils/nix-ipmi";
        ref = "master";
      }) { });
      # …
    })
  ];
};
```

Add a `ipmi` package to your package collection:

#### Wrapper

You could create a new package, which wraps `ipmi` package with
default environment variables, for example:
``` nix
(stdenv.mkDerivation {
  name = "ipmi";
  builder = writeScript "builder.sh" (''
    source $stdenv/setup
    mkdir -p $out/bin
    cat > $out/bin/ipmi <<'EOF'
    #!${bash}/bin/bash
    IPMI_HOST=$1 IPMI_OUTPUT=/tmp/$IPMI_HOST.jviewer.jnlp     \
    IPMI_USER=ADMIN IPMI_PASSWORD=$(cat $HOME/.ipmi_password) \
    ${ipmi}/bin/ipmi
    EOF
    chmod 555 $out/bin/ipmi
  '');
})
```
`$HOME/.ipmi_password` is a plain text file, but you could use GPG or
password manager like password-store.

Prefetch jdk-7u75-linux-x64.tar.gz in your Nix Store.

## Using Nix IPMI

To use Nix IPMI just call ipmi with a server name, for example:

``` shell
ipmi jenkins.ipmi
```

If you have the following error, launch "ControlPanel" from a
terminal, then in "Security" tab set "Security Level" to "Medium".

> Your security settings have blocked a self-signed application from running

## Contributing to Nix IPMI

1. Fork this repository.
2. Create a branch: `git checkout -b <branch_name>`.
3. Make your changes and commit them: `git commit -m '<commit_message>'`
4. Push to the original branch: `git push origin <project_name>/<location>`
5. Create the pull request.

## Contributors

Thanks to the following people who have contributed to this project:

* [@zdetovetskiy](https://gitlab.intr/users/zdetovetskiy/)

## Contact

If you want to contact me you can reach me at <go.wigust@gmail.com>.

## License

This project uses the following license: [GPL3+](https://www.gnu.org/licenses/gpl-3.0.en.html).
