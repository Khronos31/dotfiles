#!/bin/sh

#
# Khronos31 | ish-setup.sh
#
# legacy: 2026-07-07時点で不使用（サブスマホiPhone15にiSH自体は入れているが常用していない）。
# Alpineバージョンもv3.18で固定されたまま古くなっている。再度使うことになったら要更新。
#

echo https://dl-cdn.alpinelinux.org/alpine/v3.18/main >> /etc/apk/repositories
echo https://dl-cdn.alpinelinux.org/alpine/v3.18/community >> /etc/apk/repositories
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

