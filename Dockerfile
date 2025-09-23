# syntax=docker/dockerfile:1

FROM ghcr.io/linuxserver/baseimage-selkies:ubuntunoble

# set version label
ARG BUILD_DATE
ARG VERSION
ARG GZDOOM_VERSION
LABEL build_version="Linuxserver.io version:- ${VERSION} Build-date:- ${BUILD_DATE}"
LABEL maintainer="thelamer"

# title
ENV TITLE=GZDoom \
    DOOMWADDIR="/config/Desktop"

RUN \
  echo "**** add icon ****" && \
  curl -o \
    /usr/share/selkies/www/icon.png \
    https://raw.githubusercontent.com/linuxserver/docker-templates/master/linuxserver.io/img/gzdoom-logo.png && \
  echo "**** install packages ****" && \
  DOWNLOAD_URL=$(curl -sX GET "https://api.github.com/repos/ZDoom/gzdoom/releases/latest" \
    | awk -F '(": "|")' '/browser.*amd64.deb/ {print $3}') && \
  curl -o \
    /tmp/gzdoom.deb -L \
    "${DOWNLOAD_URL}" && \
  cd /tmp && \
  apt-get update && \
  apt-get update && \
  apt install -y \
    ./gzdoom.deb \
    unzip && \
  echo "**** install freedoom ****" && \
  FREEDOOM_URL=$(curl -sX GET "https://api.github.com/repos/freedoom/freedoom/releases/latest" \
    | awk -F '(": "|")' '/browser.*freedoom-.*.zip/ && !/.*sig/ {print $3}') && \
  curl -o \
    /tmp/freedoom.zip -L \
    "${FREEDOOM_URL}" && \
  unzip freedoom.zip && \
  mv \
    freedoom*/freedoom1.wad \
    /defaults/ && \
  echo "**** cleanup ****" && \
  apt-get autoclean && \
  rm -rf \
    /config/.cache \
    /var/lib/apt/lists/* \
    /var/tmp/* \
    /tmp/*

# add local files
COPY /root /

# ports and volumes
EXPOSE 3001

VOLUME /config
