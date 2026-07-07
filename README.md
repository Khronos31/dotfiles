# dotfiles

Khronos31 個人用のシェル設定・環境構築スクリプト集。複数OS(macOS / Linux / Termux)で共通利用できるよう、
コマンドの有無で機能を出し分ける書き方をしている。iOS(Jailbreak / iSH)向けは現在不使用のため`legacy/`。

## 使い方

```bash
./install.sh
```

`.bash_profile` `.bashrc` `.zshrc` `.commonrc` `.common_aliases` `.gitconfig` を `$HOME` にシンボリックリンクする。
既に同名ファイルが存在する場合は `<ファイル名>-<タイムスタンプ>.old` として退避してから上書きする。

## 構成

- `.commonrc` / `.common_aliases` — bash/zsh共通の環境変数・エイリアス。GNU coreutils・クリップボード(pbcopy/xclip/termux-clipboard)
  など、コマンドの有無で自動的に機能を切り替える
- `.bashrc` / `.zshrc` / `.bash_profile` — シェル別の設定
- `setup/` — OS/環境ごとの追加パッケージインストールスクリプト(`install.sh`とは別に手動で実行する)
- `etc/` — VSCode・ターミナルなどの設定ファイル
  - [`pbcopy.ps1`](etc/pbcopy.ps1) — Windows PowerShell用 pbcopy/pbpaste。`$PROFILE` に以下を追記して読み込む:
    ```powershell
    . "<このリポジトリのパス>\etc\pbcopy.ps1"
    ```
- `docs/` — 個別の環境構築手順メモ
  - [`claude-code-termux.md`](docs/claude-code-termux.md) — Termux上でClaude Codeの最新版をフル機能で動かす手順
- `legacy/` — 現在使っていない環境向けのスクリプト。参照用に残しているだけで動作保証はしない
