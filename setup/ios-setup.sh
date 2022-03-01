#!/bin/sh

#
# Khronos31 | ios-setup.sh
#

su <<'EOS'
apt update &&
apt upgrade -y &&
apt install -y \
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
  gzip bzip2 lzip xz-utils zstd zip unzip p7zip \
  build-essential \
  clang \
  lua5.4
EOS
