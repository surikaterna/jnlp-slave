# jnlp-slave

Docker CLI 24.0.9 upgrade tracked by `redemeine-cwvo` (parent
`redemeine-4tud`). Do not put registry, Rancher, or Jenkins credentials in this
repository or in captured command output.

## Build and validate the candidate

```sh
docker build --pull --no-cache -t surikaterna/jnlp-slave:10-cwvo .

docker run --rm --entrypoint /bin/sh surikaterna/jnlp-slave:10-cwvo -ec '
  test "$(id -un)" = jenkins
  test -f /debug-flag
  id -nG | tr " " "\n" | grep -Fx users
  id -nG | tr " " "\n" | grep -Fx docker
  test "$(getent group docker | cut -d: -f3)" = 999
  test "$(docker --version)" = "Docker version 24.0.9, build 2936816"
  test "$(command -v docker)" = /usr/local/bin/docker
  ! command -v dockerd
  ! command -v containerd
  ! command -v runc
'

docker image inspect surikaterna/jnlp-slave:10-cwvo \
  --format 'User={{json .Config.User}} Entrypoint={{json .Config.Entrypoint}}'
```

The image must report `User="jenkins"`. Compare the reported entrypoint with a
freshly pulled `jenkins/inbound-agent:3355.v388858a_47b_33-14-jdk21`; this
Dockerfile intentionally inherits it unchanged:

```sh
docker image inspect jenkins/inbound-agent:3355.v388858a_47b_33-14-jdk21 \
  --format 'Entrypoint={{json .Config.Entrypoint}}'
```

If a disposable Docker daemon is available, also prove client/daemon
communication using the site's approved socket or remote-daemon procedure. Do
not expose a daemon or copy credentials into the image.

## Approval and immutable release

Stop after candidate validation until the owner of `redemeine-cwvo` records
approval. After approval, authenticate through the approved credential manager,
then publish the candidate and record its registry digest. Never overwrite
`:9`, and treat `:10` as immutable once pushed.

```sh
docker push surikaterna/jnlp-slave:10-cwvo
docker pull surikaterna/jnlp-slave:10-cwvo
CANDIDATE_DIGEST="$(docker image inspect surikaterna/jnlp-slave:10-cwvo \
  --format '{{index .RepoDigests 0}}')"
printf '%s\n' "$CANDIDATE_DIGEST"

docker tag surikaterna/jnlp-slave:10-cwvo surikaterna/jnlp-slave:10
docker push surikaterna/jnlp-slave:10
docker pull surikaterna/jnlp-slave:10
RELEASE_DIGEST="$(docker image inspect surikaterna/jnlp-slave:10 \
  --format '{{index .RepoDigests 0}}')"
printf '%s\n' "$RELEASE_DIGEST"
test "$CANDIDATE_DIGEST" = "$RELEASE_DIGEST"
```

Record the final `surikaterna/jnlp-slave@sha256:...` digest on
`redemeine-cwvo` before rollout. The candidate and release tags must resolve to
the same digest.

## Rancher rollout and rollback

1. In Rancher, open the Jenkins stack and its `djangoslave` service. Record the
   current image reference/digest, replica count, and deployment settings on
   `redemeine-cwvo`.
2. Change only the service image to the recorded immutable
   `surikaterna/jnlp-slave@sha256:...` digest for release `:10` and deploy.
3. Confirm the service becomes healthy, Jenkins agents reconnect, and a
   disposable job can run `docker --version` and the required Docker operation.
4. If health checks, agent connection, or Docker jobs fail, restore the exact
   image reference/digest and settings recorded in step 1, redeploy, and verify
   the agents reconnect. Release `:9` remains untouched as a rollback option.

Attach validation, approval, digest, rollout, and any rollback evidence to
`redemeine-cwvo`, linked to parent `redemeine-4tud`.
