# Khronos31 | pbcopy.ps1
#
# PowerShell用 pbcopy/pbpaste 相当のコマンド。
# $PROFILE から dot-source して使う:
#   . "path\to\dotfiles\etc\pbcopy.ps1"

function pbcopy {
    [Console]::OutputEncoding = [System.Text.Encoding]::UTF8
    $text = [Console]::In.ReadToEnd()
    Set-Clipboard -Value $text
}

function pbpaste {
    [Console]::OutputEncoding = [System.Text.Encoding]::UTF8
    Get-Clipboard -Raw
}
