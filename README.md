# dotfiles セットアップ手順

Windows PC でこのリポジトリの設定を各アプリの設定ディレクトリへシンボリックリンクします。

## 前提

- Git が使えること
- PowerShell が使えること
- シンボリックリンクを作成できること

Windows では、Developer Mode が無効な場合、シンボリックリンク作成に管理者権限が必要です。

## リポジトリを配置する

例として、ホームディレクトリ直下に `dotfiles` を置きます。

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
