# Termux で Claude Code を最新版フル機能で動かす

2026-07-07 に判明した問題と、その解決手順。

## 問題

`npm install -g @anthropic-ai/claude-code` で入れても、Termux(Android)では動かない。

```
Error: claude native binary not installed.
```

postinstall を手動実行すると根本原因が分かる:

```
[@anthropic-ai/claude-code postinstall] Native binaries for linux-arm64-android are not available on this release channel.
  Available: darwin-arm64, darwin-x64, linux-x64, linux-arm64, linux-x64-musl, linux-arm64-musl, win32-x64, win32-arm64
```

**バージョン 2.1.113 以降、Android(Termux)向けネイティブバイナリの配布が打ち切られた。** CPU(aarch64)は一致しているが、
Termux は Android の `Bionic` libc を使っており、`glibc`/`musl` どちらとも ABI が異なるため、既製バイナリがそのまま動かない。

## 簡易な回避策(手っ取り早いが最新版は使えない)

`2.1.112` に固定すれば Android 向けバイナリがまだ存在するため、そのまま動く。

```bash
npm uninstall -g @anthropic-ai/claude-code
npm install -g --allow-scripts=@anthropic-ai/claude-code @anthropic-ai/claude-code@2.1.112
```

ただし自動更新で 2.1.113+ に巻き戻されて再発するため、`~/.claude/settings.json` で自動更新を止める:

```json
{
  "env": { "DISABLE_AUTOUPDATER": "1" }
}
```

この場合、CLIの `/model` に新モデルが出てこないが、`--model claude-sonnet-5` のようにフルネームを明示すれば
API 自体は問題なく通る(CLI 側の候補一覧に無いだけ)。

`proot-distro` で Ubuntu 等を丸ごと偽装する手もあるが、起動が重くなる上に大掛かりなので非推奨。

## 本命の解決策: patchelf + musl ランタイム + proot(単発bind mount)

最新版をフル機能・そこそこ軽量に動かす方法。要点は3つ:

1. `linux-arm64-musl` 版バイナリを取得し、`patchelf` でインタプリタパスを書き換える
   (Alpine 公式配布物から musl ランタイムだけ拝借して Termux 内に設置)
2. `LD_PRELOAD` を解除する(Termux が全プロセスに強制注入する Bionic 専用フックが
   musl バイナリだと symbol not found でクラッシュするため)
3. `/etc/resolv.conf` が存在しない(Android は伝統的な DNS 解決ファイルを使わない)ため、
   名前解決ができず `FailedToOpenSocket` になる。`proot` で「1ファイルだけ」bind mount して回避する
   (proot-distro のようにディストリ全体を偽装する必要はない)

### セットアップ手順

```bash
# 1. 必要ツールを導入
pkg install -y patchelf proot

# 2. Alpine から musl ランタイムを拝借
mkdir -p ~/musl-compat/tmp && cd ~/musl-compat/tmp
LATEST_ALPINE=$(curl -fsSL https://dl-cdn.alpinelinux.org/alpine/latest-stable/releases/aarch64/ \
  | grep -o 'alpine-minirootfs-[0-9.]*-aarch64.tar.gz' | head -1)
curl -fsSL -o alpine.tar.gz "https://dl-cdn.alpinelinux.org/alpine/latest-stable/releases/aarch64/${LATEST_ALPINE}"
tar -xzf alpine.tar.gz ./lib/libc.musl-aarch64.so.1 ./lib/ld-musl-aarch64.so.1

mkdir -p ~/musl-compat/lib
cp lib/ld-musl-aarch64.so.1 ~/musl-compat/lib/
ln -sf ld-musl-aarch64.so.1 ~/musl-compat/lib/libc.musl-aarch64.so.1

# libgcc / libstdc++ も同様に Alpine の apk から抜く(バージョンは適宜最新に読み替え)
curl -fsSL -o libgcc.apk https://dl-cdn.alpinelinux.org/alpine/v3.24/main/aarch64/libgcc-15.2.0-r5.apk
curl -fsSL -o libstdcxx.apk https://dl-cdn.alpinelinux.org/alpine/v3.24/main/aarch64/libstdc++-15.2.0-r5.apk
tar -xzf libgcc.apk -O usr/lib/libgcc_s.so.1 > ~/musl-compat/lib/libgcc_s.so.1
tar -xzf libstdcxx.apk -O usr/lib/libstdc++.so.6.0.34 > ~/musl-compat/lib/libstdc++.so.6

# 3. DNS 用のダミー resolv.conf
echo 'nameserver 8.8.8.8' > ~/musl-compat/resolv.conf
echo 'nameserver 1.1.1.1' >> ~/musl-compat/resolv.conf

# 4. 最新版 musl バイナリを取得してパッチ
mkdir -p ~/musl-compat/latest-test
npm install --no-save --force --prefix ~/musl-compat/latest-test \
  @anthropic-ai/claude-code-linux-arm64-musl@latest
cp ~/musl-compat/latest-test/node_modules/@anthropic-ai/claude-code-linux-arm64-musl/claude \
  ~/musl-compat/claude-latest-patched
patchelf --set-interpreter ~/musl-compat/lib/ld-musl-aarch64.so.1 \
  --set-rpath ~/musl-compat/lib ~/musl-compat/claude-latest-patched

# 5. claude コマンドをラッパーに置き換え
rm -f /data/data/com.termux/files/usr/bin/claude
cat > /data/data/com.termux/files/usr/bin/claude << 'EOF'
#!/data/data/com.termux/files/usr/bin/bash
unset LD_PRELOAD
exec proot -b "$HOME/musl-compat/resolv.conf:/etc/resolv.conf" "$HOME/musl-compat/claude-latest-patched" "$@"
EOF
chmod +x /data/data/com.termux/files/usr/bin/claude

# 6. 自動更新を無効化(パッチしたバイナリが上書きされないように)
mkdir -p ~/.claude
python3 -c "
import json, os
path = os.path.expanduser('~/.claude/settings.json')
d = {}
if os.path.exists(path):
    with open(path) as f: d = json.load(f)
d.setdefault('env', {})['DISABLE_AUTOUPDATER'] = '1'
with open(path, 'w') as f: json.dump(d, f, indent=2)
"

# 動作確認
claude --version
```

### 今後のバージョン更新

手順4〜5相当を自動化した `~/musl-compat/update-claude.sh` を作成済み。
`/data/data/com.termux/files/usr/bin/claude-update` にシンボリックリンクしてあるので、

```bash
claude-update
```

を叩くだけで、最新版取得→patchelf適用→動作確認(失敗時は既存バイナリを維持)まで自動で行う。

## ハマりどころメモ

- **`which` が Termux に無い**。`type` や `command -v` を使うか、パスを直接 `ls` で確認する
- **`bash -lc` はログインシェルとして `.bashrc` を読まない**。`.bashrc` に書いた設定を SSH 一発コマンドで
  検証したいときは `bash -ic '...'` (対話・非ログイン)を使う。逆に `.profile` にも書いておくと安全
- **SSH の一発コマンド実行(`ssh host "cmd"`)は非対話・非ログインシェル**。`.bashrc` を経由しないため、
  シェル起動ファイルに頼った環境変数は効かない。確実に効かせたいならコマンドの頭に明示的に
  `DISABLE_AUTOUPDATER=1 claude ...` のように付けるか、アプリ自身の設定ファイル
  (`~/.claude/settings.json`)に書く方が堅牢
- **`/lib`・`/etc` はAndroidの読み取り専用領域で書き込み不可**(root権限が必要)。Termux の書き込み可能領域は
  `$PREFIX`(`/data/data/com.termux/files/usr`)配下のみ
- **npm の `optionalDependencies` によるプラットフォーム判定は `--force` で上書き可能**
  (`npm install --force <platform-package>@<version>`)。ただし ABI の壁自体は解決しないので、
  結局 patchelf 等の追加対応が要る
