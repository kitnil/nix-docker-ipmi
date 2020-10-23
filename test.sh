#!/usr/bin/env bash
nix-shell --pure --run 'ipmi ADMIN web16.ipmi.intr' --show-trace
