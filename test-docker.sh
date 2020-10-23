#!/usr/bin/env bash
docker load < $(nix-build docker.nix) ; xhost +local:; docker run --rm --network=host --tty --interactive --user 1000:997 --env DISPLAY=$DISPLAY --volume /etc/localtime:/etc/localtime:ro --volume /tmp:/tmp --volume /tmp:/home/alice  docker-registry.intr/utils/nix-ipmi:latest ADMIN web16.ipmi
