# dotfiles

Khronos31 個人用のシェル設定・環境構築スクリプト集。複数OS(macOS / Linux / Termux)で共通利用できるよう、
コマンドの有無で機能を出し分ける書き方をしている。iOS(Jailbreak / iSH)向けは現在不使用のため`legacy/`。

## 使い方

```bash
./install.sh
```

`.profile` `.bash_profile` `.bashrc` `.zshenv` `.zshrc` `.shrc` `.common_env` `.commonrc` `.common_aliases` `.gitconfig` を
`$HOME` にシンボリックリンクする。
既に同名ファイルが存在する場合は `<ファイル名>-<タイムスタンプ>.old` として退避してから上書きする。

## 構成

設定を**環境変数の層**と**対話シェルの層**に分けている。シェルの起動には
「ログインか否か」と「対話か否か」という直交する2軸があり、混ぜると
`ssh host 'コマンド'` のような非対話シェルに環境変数が届かなかったり、
逆に入口が複数あるせいで PATH が重複したりする。

- `.common_env` — bash/zsh共通の**環境変数**(PATH・LANG)。POSIX shで書く
  (デスクトップセッションが `~/.profile` を `/bin/sh` で読むため)。`.profile` /
  `.bashrc` / `.zshenv` の複数経路から読まれるので、PATH操作は冪等にしてある
- `.commonrc` / `.common_aliases` — bash/zsh共通の**対話シェル用**設定。エイリアス・
  プロンプト・関数。GNU coreutils・クリップボード(pbcopy/xclip/termux-clipboard)など、
  コマンドの有無で自動的に機能を切り替える

### `pbcopy` の既定は OSC 52（2026-09-09に仕様変更）

`pbcopy` は既定で**端末のOSC 52シーケンス**を使い、「手元の」クリップボードへ送る。
SSH越しに使う場面が圧倒的に多く、既定が「繋いだ先のクリップボード」を指しているのは
実態と噛み合わなかったため反転した。

| 呼び方 | 送り先 |
|---|---|
| `pbcopy` | OSC 52（端末＝手元） |
| `pbcopy --osc52` | 同上（旧来の綴り。既定と同じ） |
| `pbcopy --native` | その機械のクリップボード実体（`xclip` / `pbcopy` / `termux-clipboard-set` / `/dev/clipboard`） |

`--native` を指定しても実体が無い場合は、stderrに断ったうえでOSC 52へ回す
（パイプで渡された内容を黙って捨てないため）。不明なオプションは `exit 2`。

⚠️ OSC 52は**端末側の対応が要る**。未対応の端末では黙って何も起きない
（例: Studio Code Server の統合ターミナルは非対応）。その場合は `--native` を使う。
`pbpaste` は従来どおりネイティブのみ——OSC 52の読み出しは対応端末が少なく、
セキュリティ上無効化されていることが多いため。
- `.profile` / `.bash_profile` / `.bashrc` / `.zshenv` / `.zshrc` / `.shrc` — シェル別の入口。
  上の2つを適切な層で読むだけ + シェル固有の設定(ヒストリ・プロンプト・補完)

| 入口 | 読まれる場面 | `.common_env` | `.commonrc` |
|---|---|---|---|
| `.profile` | デスクトップログイン / sh のログインシェル | ✅ | — |
| `.bash_profile` | bash のログインシェル | ✅ | ✅ |
| `.bashrc` | bash の対話シェル / sshd 経由の非対話 bash | ✅ | 対話時のみ |
| `.zshenv` | zsh の全起動 | ✅ | — |
| `.zshrc` | zsh の対話シェル | — | ✅ |
| `.shrc` | ash/dash/ksh の対話シェル（`$ENV` 経由。Alpine 等でログインシェルが `/bin/sh` の環境） | ✅ | ✅ |

`$HOME/.common_env.local` があれば `.common_env` の最後に読む(このリポジトリでは追跡しない)。
コマンドの有無で判定できないもの — 「この機械にこれを入れた」という事実そのもの — を置く。
`path_prepend` が使える。

```sh
# ~/.common_env.local の例
path_prepend "$HOME/.grok/bin"
export DISABLE_AUTOUPDATER=1
```

対話用の機械固有設定は `$HOME/.commonrc.local`(同じく追跡しない)。`.common_env.local` は
POSIX sh で読まれるため `[[ ]]` や補完の読み込みが書けない。それらはこちらへ置く。

どちらも `install.sh` がコメントだけの雛形を置く。**既にある場合は中身を持っているため、
上書きも `.old` への退避もしない**(追跡ファイルへの symlink と違い、復元元が無いため)。

### 既知の制限: 非対話 bash に PATH が届かない環境がある

bash は非対話かつ非ログインだと起動ファイルを一切読まない。例外として、sshd 経由で
起動された場合に `~/.bashrc` を読む挙動があるが、これは `SSH_SOURCE_BASHRC` 付きで
ビルドされている場合に限る。

| 環境 | `SSH_SOURCE_BASHRC` | `ssh <host> 'コマンド'` に PATH が届くか |
|---|---|---|
| Debian / Ubuntu | あり | 届く |
| **Termux** | **無し** | **届かない** |
| zsh (全環境) | — | 届く(`.zshenv` を必ず読むため) |

確認方法: `strings "$(command -v bash)" | grep -qx SSH_CLIENT`

Termux 機へ非対話でコマンドを送る場合は、PATH を当てにせず絶対パスで呼ぶか、
`ssh <host> 'bash -lc "コマンド"'` のようにログインシェルを明示する。
- `setup/` — OS/環境ごとの追加パッケージインストールスクリプト(`install.sh`とは別に手動で実行する)
- `etc/` — VSCode・ターミナルなどの設定ファイル
  - [`pbcopy.ps1`](etc/pbcopy.ps1) — Windows PowerShell用 pbcopy/pbpaste。`$PROFILE` に以下を追記して読み込む:
    ```powershell
    . "<このリポジトリのパス>\etc\pbcopy.ps1"
    ```
- `docs/` — 個別の環境構築手順メモ
  - [`claude-code-termux.md`](docs/claude-code-termux.md) — Termux上でClaude Codeの最新版をフル機能で動かす手順
- `legacy/` — 現在使っていない環境向けのスクリプト。参照用に残しているだけで動作保証はしない
