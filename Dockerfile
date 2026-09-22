FROM jenkins/inbound-agent:3355.v388858a_47b_33-14-jdk21

USER root

ENV DOCKER_VERSION 24.0.9
ENV DOCKER_SHA256 692ecfc28333485d184f628b74c25b2894cee9495a51a5418ba60ef95bf733ca
RUN set -eux \
	&& apt-get update \
	&& apt-get install -y --no-install-recommends curl ca-certificates \
	&& curl -fSL "https://download.docker.com/linux/static/stable/x86_64/docker-${DOCKER_VERSION}.tgz" -o docker.tgz \
	&& echo "${DOCKER_SHA256} *docker.tgz" | sha256sum -c - \
	&& tar -xzf docker.tgz docker/docker \
	&& install -m 0755 docker/docker /usr/local/bin/docker \
	&& rm -rf docker docker.tgz \
	&& rm -rf /var/lib/apt/lists/* \
	&& docker --version \
    && groupadd -g 999 docker \
    && gpasswd -a jenkins users \
    && gpasswd -a jenkins docker

RUN touch /debug-flag
USER jenkins
