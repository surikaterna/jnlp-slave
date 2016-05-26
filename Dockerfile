FROM jenkinsci/jnlp-slave

ENV DOCKER_BUCKET get.docker.com
ENV DOCKER_VERSION 1.11.1
ENV DOCKER_SHA256 893e3c6e89c0cd2c5f1e51ea41bc2dd97f5e791fcfa3cee28445df277836339d
ENV DOCKER_HOME /usr/bin/docker
ENV DOCKER_HOST unix:///var/run/docker.sock

USER root

RUN curl -fSL "https://${DOCKER_BUCKET}/builds/Linux/x86_64/docker-$DOCKER_VERSION.tgz" -o ${DOCKER_HOME} \
    && echo "${DOCKER_SHA256} ${DOCKER_HOME}" | sha256sum -c - \
    && chmod +x ${DOCKER_HOME}

#RUN usermod -G docker jenkins

USER jenkins
