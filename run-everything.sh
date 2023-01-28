docker_cmd=docker

if command -v podman; then
    docker_cmd=podman
fi

${docker_cmd} run -d --name derp_postgres --rm -v derp_db:/var/lib/postgresql/data -p 5432:5432 -e POSTGRES_PASSWORD=password postgres:alpine

# Hack to (re)set correct permissions
${docker_cmd} run --rm -it \
    -v derp_ipfs_data:/data/ipfs:Z \
    --entrypoint /bin/chown \
    ipfs/kubo:latest  \
    -R ipfs:users /data/ipfs/datastore

${docker_cmd} run --name derp_ipfs --rm -it \
    -v derp_ipfs_host:/export:Z \
    -v derp_ipfs_data:/data/ipfs:Z \
    -p 4001:4001 \
    -p 4001:4001/udp  \
    -p 127.0.0.1:8085:8080 \
    -p 127.0.0.1:5001:5001 \
    ipfs/kubo:latest
# pushd smart_contract
# ./run-truffle.sh
# popd
