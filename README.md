# dotfiles セットアップ手順

NixOS-WSLとWindowsの設定を管理します。

## NixOS-WSL

対象はx86_64のNixOS-WSL、ユーザー名は`nixos`です。リポジトリを
`/home/nixos/dotfiles`へcloneし、以下を実行します。Neovim設定もこの配置を参照します。

```bash
cd /home/nixos/dotfiles
sudo bash ./install-nixos.sh
sudo nixos-rebuild switch --flake /etc/nixos#nixos
```

`install-nixos.sh`は`/etc/nixos`をこのチェックアウトへのシンボリックリンクにします。
既存の設定は`/etc/nixos.backup-XXXXXXXX/nixos`へ退避し、そのパスを表示します。
同じチェックアウトを参照している場合は変更せず終了します。スクリプト自体は
システムの再構築を行いません。

設定変更後も上記の`nixos-rebuild`で適用します。依存バージョンは`flake.lock`で固定します。
Windows側のWSL設定、認証情報、Neovimが別途取得するプラグインの状態は含みません。

参照先の確認：

```bash
readlink -f /etc/nixos
```

元の設定へ戻す場合は、リンクがこのチェックアウトを指していることを確認してから、
`sudo unlink /etc/nixos`を実行し、表示された退避先を`sudo mv <退避先>/nixos /etc/nixos`で戻します。

## Windows

Windows PCで各アプリの設定ディレクトリへシンボリックリンクします。

## 前提

- Git が使えること
- PowerShell が使えること
- シンボリックリンクを作成できること

## リポジトリを配置する

ホームディレクトリ直下に `dotfiles` を置きます。

```powershell
cd $env:USERPROFILE
git clone <このリポジトリのURL> dotfiles
cd dotfiles
```

## セットアップを実行する

管理者権限の PowerShell で実行します。

リポジトリの場所に合わせてパスを変更します。

```powershell
powershell -ExecutionPolicy Bypass -File $env:USERPROFILE\dotfiles\install.ps1
```

## 作成されるリンク

`install.ps1` は次のリンクを作成します。

```text
%LOCALAPPDATA%\nvim        -> <repo>\nvim
%USERPROFILE%\.config\wezterm -> <repo>\wezterm
%USERPROFILE%\.config\nushell -> <repo>\nushell
```

リンク先の親ディレクトリが存在しない場合は、自動で作成します。

## 既存設定の扱い

既に同じパスに設定ディレクトリやシンボリックリンクがある場合、`install.ps1` はそれを削除してから新しいリンクを作成します。

対象:

```text
%LOCALAPPDATA%\nvim
%USERPROFILE%\.config\wezterm
%USERPROFILE%\.config\nushell
```

必要な設定が残っている場合は、実行前に手動で退避してください。

## 再実行

設定を張り直したい場合も、同じコマンドを再実行します。

```powershell
powershell -ExecutionPolicy Bypass -File $env:USERPROFILE\dotfiles\install.ps1
```

## CLIツール管理
Scoopを利用して管理します。

### 初回インストール時
```powershell
scoop import apps.json
```

### パッケージ追加時
JSONファイルをアップデートします。
```powershell
scoop export > ~/dotfiles/scoop.json
```
```nu
scoop export | save -f ~/dotfiles/scoop.json
```

