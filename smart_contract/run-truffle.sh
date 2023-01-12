#!/usr/bin/sh

podman build . -t truffle --target truffle

podman run --rm -it -v .:/app:Z -p 9545:9545 truffle
