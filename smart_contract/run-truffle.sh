docker_cmd=docker

if command -v podman; then
    docker_cmd=podman
fi

# ${docker_cmd} build . -t truffle --target truffle

${docker_cmd} run -it --rm -v ${PWD}:/app:Z -p 9545:9545 truffle
