#!/data/data/com.termux/files/usr/bin/sh

#
# Khronos31 | termux-setup.sh
#

apt update &&
apt upgrade -y &&
apt install -y $(cat <<'PACKAGES' | grep -v '^\s*#' | tr '\n' ' '
root-repo
termux-api
bash
zsh
vim
git
coreutils
findutils
grep
sed
gawk
file
wget
curl
openssh
tar
gzip
bzip2
lzip
xz-utils
zstd
zip
unzip
p7zip
# clang: 自前でC/C++をビルドする用途が今は無いので停止（2026-07-07）。再度要る時にコメントを外す
lua54
nodejs
npm
patchelf
proot
PACKAGES
)

termux-setup-storage
