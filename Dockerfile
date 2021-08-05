FROM docker:20.10-dind

# Build-time metadata as defined at http://label-schema.org
ARG BUILD_DATE
ARG VCS_REF
ARG VERSION
LABEL org.label-schema.build-date=$BUILD_DATE \
      org.label-schema.name="Docker in Docker ${DOCKER_VERSION} (${DOCKER_CHANNEL})" \
      org.label-schema.description="Docker in Docker ${DOCKER_VRSION} (${DOCKER_CHANNEL}) + latest docker-compose" \
      org.label-schema.vcs-ref=$VCS_REF \
      org.label-schema.vcs-url="https://github.com/meyayl/docker-dind" \
      org.label-schema.version=$VERSION \
      org.label-schema.schema-version="1.0"

ENV S6_BEHAVIOUR_IF_STAGE2_FAILS=2 TZ="Europe/Berlin"

RUN \
  echo "**** install s6-overlay ****" && \
  apk add --no-cache tzdata curl bash git expect && \
  curl -L -s https://github.com/just-containers/s6-overlay/releases/download/v2.2.0.3/s6-overlay-amd64.tar.gz | tar xvzf - -C / && \
  echo "**** compile docker-compose and remove build packages ****" && \
  apk add --no-cache py3-pip python3-dev libffi-dev openssl-dev gcc libc-dev make && \
  pip3 install --no-cache-dir docker-compose && \
  apk del make libc-dev gcc openssl-dev libffi-dev python3-dev && \
  echo "**** cleanup ****" && \
  rm -rf /tmp/*

COPY root/ /
CMD ["/init"]
