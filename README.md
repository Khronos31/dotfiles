# dotfiles

Khronos31 個人用のシェル設定・環境構築スクリプト集。複数OS(macOS / Linux / Termux)で共通利用できるよう、
コマンドの有無で機能を出し分ける書き方をしている。iOS(Jailbreak / iSH)向けは現在不使用のため`legacy/`。

## 使い方

```bash
./install.sh
```

`.profile` `.bash_profile` `.bashrc` `.zshenv` `.zshrc` `.common_env` `.commonrc` `.common_aliases` `.gitconfig` を
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
- `.profile` / `.bash_profile` / `.bashrc` / `.zshenv` / `.zshrc` — シェル別の入口。
  上の2つを適切な層で読むだけ + シェル固有の設定(ヒストリ・プロンプト・補完)

| 入口 | 読まれる場面 | `.common_env` | `.commonrc` |
|---|---|---|---|
| `.profile` | デスクトップログイン / sh のログインシェル | ✅ | — |
| `.bash_profile` | bash のログインシェル | ✅ | ✅ |
| `.bashrc` | bash の対話シェル / sshd 経由の非対話 bash | ✅ | 対話時のみ |
| `.zshenv` | zsh の全起動 | ✅ | — |
| `.zshrc` | zsh の対話シェル | — | ✅ |

`$HOME/.common_env.local` があれば `.common_env` の最後に読む(このリポジトリでは追跡しない)。
コマンドの有無で判定できないもの — 「この機械にこれを入れた」という事実そのもの — を置く。
`path_prepend` が使える。

```sh
# ~/.common_env.local の例
path_prepend "$HOME/.grok/bin"
```
- `setup/` — OS/環境ごとの追加パッケージインストールスクリプト(`install.sh`とは別に手動で実行する)
- `etc/` — VSCode・ターミナルなどの設定ファイル
  - [`pbcopy.ps1`](etc/pbcopy.ps1) — Windows PowerShell用 pbcopy/pbpaste。`$PROFILE` に以下を追記して読み込む:
    ```powershell
    . "<このリポジトリのパス>\etc\pbcopy.ps1"
    ```
- `docs/` — 個別の環境構築手順メモ
  - [`claude-code-termux.md`](docs/claude-code-termux.md) — Termux上でClaude Codeの最新版をフル機能で動かす手順
- `legacy/` — 現在使っていない環境向けのスクリプト。参照用に残しているだけで動作保証はしない
