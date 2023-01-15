#!/usr/bin/sh


docker_cmd=docker

if command -v podman; then
    docker_cmd=podman
fi

${docker_cmd} run -d --name derp_postgres --rm -v derp_db:/var/lib/postgresql/data -p 5432:5432 -e POSTGRES_PASSWORD=password postgres:alpine
# pushd smart_contract
# ./run-truffle.sh
# popd
