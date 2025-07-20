---
title: "タイトルで補完してSteamのゲームを起動できるFishのプラグインを作ったよ"
emoji: "🐟"
type: "tech"
topics: [fish, steam, jq]
published: true
published_at: "2025-07-20 19:00"
---
Steam のゲームをする時ってコマンド・ラインから`$ steam steam://rungameid/<ゲームのID>`ってやってる人が多いと思うんですが、普段やるゲームならいざ知らず、新しいゲームを始める度に ID を調べるのはちょっと手間ですよね。
そこで、Steam にあるゲームのリストから、fish の補完を出すようにしてみました。
![](/images/fish-steam-play-01.gif)

リポジトリはこちら。
https://github.com/NI57721/fish-steam-play

# 使い方
[Fisher](https://github.com/jorgebucaran/fisher) でインストールしてください。
初回起動時に Steam のゲームのリストを取ってきます。
`-f`か`--fetch`オプションを付けて実行することで明示的にリストを取得することもできます。
```fish
fisher install NI57721/fish-steam-play
```

## 環境変数
`STEAM_PLAY_STATE` によってゲームのリストの保存先を指定できます。
デフォルトでは`$XDG_STATE_HOME/steam-play`です。

## 制作秘話
ゲームのリストが数十万件あるので、PoC 段階では補完の表示に時間が掛かってしまうことがありました。
整形済みの補完データをキャッシュしたり、入力が0～2文字の時は補完を無効にしたりすることで対処しました。

