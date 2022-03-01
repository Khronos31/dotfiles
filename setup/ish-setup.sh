#!/bin/sh

#
# Khronos31 | ish-setup.sh
#

echo https://dl-cdn.alpinelinux.org/alpine/v3.14/main >> /etc/apk/repositories
echo https://dl-cdn.alpinelinux.org/alpine/v3.14/community >> /etc/apk/repositories
sed -i -e '/http:\/\/apk.ish.app/d' /etc/apk/repositories

apk update &&
apk upgrade &&
apk add \
  bash zsh \
  sudo \
  vim \
  git \
  coreutils \
  findutils \
  grep \
  sed \
  gawk \
  file \
  wget curl \
  openssh \
  tar \
  gzip bzip2 lzip xz zstd zip unzip p7zip \
  alpine-sdk \
  musl-dev \
  libc6-compat \
  clang lld \
  lua5.4

adduser mobile -s /bin/bash <<'EOF'
alpine
alpine
EOF

echo '%mobile ALL=(ALL) ALL' >> /etc/sudoers.d/mobile

