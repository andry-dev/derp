#!/usr/bin/sh


docker_cmd=docker

if command -v podman; then
    docker_cmd=podman
fi

${docker_cmd} run -d --name derp_postgres --rm -v derp_db:/var/lib/postgresql/data -p 5432:5432 -e POSTGRES_PASSWORD=password postgres:alpine

${docker_cmd} run -d --name derp_ipfs --rm \
    -v derp_ipfs_host:/export \
    -v derp_ipfs_data:/data/ipfs \
    -p 4001:4001 \
    -p 4001:4001/udp  \
    -p 127.0.0.1:8085:8080 \
    -p 127.0.0.1:5001:5001 \
    ipfs/kubo:latest
# pushd smart_contract
# ./run-truffle.sh
# popd
