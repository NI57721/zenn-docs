---
title: "キー1つでGitHubで見ているリポジトリを即座にクローンしてターミナルで開く"
emoji: "♊"
type: "tech"
topics: [terminal, browser, git]
published: true
published_at: "2025-07-20 12:00"
---
ブラウザで GitHub のリポジトリを見ていて、ちょっとクローンして手許で確認してみたくなることってありますよね。
今回はこの作業はホット・キー1つで完了できるような設定をご紹介します。

下の動画ではブラウザで GitHub を閲覧時に`Alt-P`を押下するだけで、`git clone` してクローン先に移動した状態のターミナルに移動しています。
![](/images/browser-and-terminal-01.gif)

# 環境
ウィンドウ・マネージャ: [Sway](https://github.com/swaywm/sway)
ターミナル・エミュレータ: [Wezterm](https://github.com/wezterm/wezterm)
キー・リマッパ: [xremap](https://github.com/xremap/xremap)
OS: [Arch Linux](https://archlinux.org/), [Wayland](https://wayland.freedesktop.org/)

# 設定
## キー・リマッパ
Google Chrome を使用中に `Alt-P` を押下すると専用の Bash スクリプトを実行するように xremap を設定しています。[^xremap]
```yaml:config.yaml
keymap:
  - application:
      only: google-chrome
    remap:
      M-P:
        launch: ["bash", "-c", "$XDG_CONFIG_HOME/xremap/scripts/clone-from-github.sh"]
```

## git clone & ターミナルに移動
上記のキーで対応付けられているのが以下のスクリプトです。
```bash:clone-from-github.sh
#!/bin/bash -eu

MAIN_WEZTERM_PID=$(swaymsg -t get_tree | jq '.. | objects | select(.app_id? == "MainTerminal") | .pid')
export WEZTERM_UNIX_SOCKET=/run/user/$(id -u)/wezterm/gui-sock-$MAIN_WEZTERM_PID

wtype -M ctrl l -s 50 -k insert -k escape
user=$(wl-paste | sed -r "s@https://github\.com/([^/?]+).*@\1@")
repository=$(wl-paste | sed -r "s@https://github\.com/[^/]+/([^/?]+).*@\1@")

if [ -z "$user" ] || [ -z "$repository" ]; then
  exit
fi

git clone git@github.com:$user/$repository ~/dev/$repository &
wezterm cli spawn --cwd ~/dev/$repository -- fish
swaymsg [app_id="^MainTerminal$"] focus
```

やっていることを大まかに説明するとこんな感じです。
1. Ctrl-L + Ctrl-insert でブラウザの URL をクリップボードにコピー
1. URL の情報からユーザ名とリポジトリ名が取得できなかったら`exit`
1. 所定の場所に`git clone`
1. クローン先をターミナルで開く
1. `4`のターミナルにフォーカスを移動する (ここまではブラウザにフォーカスがある)

`1`でブラウザから現在閲覧中の URL を取得する箇所だけ、OS にキーボードのタイプ情報を送信するという少々泥臭い手段を取っていますが、スマートな方法が無さそうなので仕方無いのかなと思います。

ターミナルを取得する場面で`app_id`が`MainTerminal`のものを指定しています。これは、私が OS の起動時に Sway の以下の設定で起動させているターミナルに付けているものです。
```sway:config
exec wezterm start --class MainTerminal
```

また、Wezterm のプロセス外から Wezterm を操作するには`WEZTERM_UNIX_SOCKET`で Wezterm のインスタンスを指定する必要があります。[^wezterm] この値は環境に依るのではないかと思います。
```bash
export WEZTERM_UNIX_SOCKET=/run/user/$(id -u)/wezterm/gui-sock-$MAIN_WEZTERM_PID
```

# おまけ ～ 今見ているページを Vim で開く ～
![](/images/browser-and-terminal-02.gif)

以下のスクリプトを特定のキーに設定しておくと `vim {URL}` を実行して即座にソースが確認できます。
「このページ、ちょっと Vim で見たいんだよなぁ」となることが結構あるかと思いますが、そういった場面で重宝しています。

```bash:open-with-vim.sh
#!/bin/bash -eu

MAIN_WEZTERM_PID=$(swaymsg -t get_tree | jq '.. | objects | select(.app_id? == "MainTerminal") | .pid')
export WEZTERM_UNIX_SOCKET=/run/user/$(id -u)/wezterm/gui-sock-$MAIN_WEZTERM_PID

wtype -M ctrl l -s 50 -k insert -k escape
wezterm cli spawn -- vim $(wl-paste)
swaymsg [app_id="^MainTerminal$"] focus
```

以上です！

------
[^xremap]: launch の部分が冗長に見えますが、環境変数がうまく展開されなかった為このような措置を取っています。
[^wezterm]: https://wezterm.org/cli/cli/
https://github.com/wezterm/wezterm/issues/4456

