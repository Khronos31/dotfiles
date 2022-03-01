#!/data/data/com.termux/files/usr/bin/sh

#
# Khronos31 | termux-setup.sh
#

apt update &&
apt upgrade -y &&
apt install -y \
  root-repo \
  termux-api \
  bash zsh \
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
  clang \
  lua54

termux-setup-storage
