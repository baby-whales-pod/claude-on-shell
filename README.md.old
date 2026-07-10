# claude-on-shell

## Build the template

```bash
cd template
DOCKER_HANDLE=philippecharriere494
TAG=0.0.1
NAME=sbx-my-claude-agent
docker buildx build --platform linux/arm64 -t ${DOCKER_HANDLE}/${NAME}:${TAG} --push .
```

## Update the value of `image` in `./kit/spec.yaml`

```yaml
agent:
  image: "docker.io/philippecharriere494/sbx-my-claude-agent:0.0.1"
```

## At the root of the repository

```bash
sbx run claude-on-shell --kit ./kit/
```