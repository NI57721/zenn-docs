---
title: "fishでコミットメッセージの一部でハッシュを補完する関数を作る"
emoji: "🥫"
type: "tech" # tech: 技術記事 / idea: アイデア
topics: ["fish", "補完"]
published: true
---
fish にはコミット・メッセージの一部からコミットのハッシュを補完する便利な機能があります。
この記事では、この機能を自分で定義した関数でも使えるようにすることを目的としています。
実際に補完される様子は下の動画をご覧ください。
![](/images/fish-completion-from-commit-message-001.gif)

やることは以下のみです。

- 関数を作る
- `complete` で補完方法を指定する。(必要なら補完用の関数を作る)

この記事では、git の fixup をシンプルに実行する関数を作ってみます。
では、順を追って見て行きましょう。

# 関数を作る
```fish
function gifu
  set --local hash $argv[1]
  git commit --fixup $hash &&
    git rebase --autostash --autosquash $hash~
end
```

コミット・ハッシュを引数に渡すとそこで fixup して rebase までしてくてるという関数です。
引数を指定する時にハッシュ値の一部やコミット・メッセージで補完できると便利ですよね。

# 補完方法を指定する
`complete`について詳しくは[公式のドキュメント](https://fishshell.com/docs/current/completions.html)や、`/usr/share/fish/completions`などにある`complete`の設定例を参考にしてください。

ここでは`complete`で補完の挙動を指定する方法を簡単に説明をします。
```fish
function my-completion
  echo -e "foo\t(first comment)\nbar\t(second comment)\nbaz\t(third comment)"
end

function foo
  echo -e "arguments are $argv."
end

complete --no-files --command foo --keep-order --arguments '(my-completion)'
```

上記の例では`--no-files`でカレント・ディレクトリにあるファイルは補完候補に入れないように設定し、`--keep-order --arguments '(my-completion)'`の部分で、`my-completion`で得られた結果を順番を変更せずに補完候補として受け取るという設定をしています。
`my-completion`は補完候補が表示される直前に評価されます。
また、`\t`以降はコメントとして扱われるようです。補完時に表示はされますが、実際に入力されるのはその手前までです。
![](/images/fish-completion-from-commit-message-002.gif)

それでは、先程定義した`fixup`用の関数にも補完方法を設定しましょう。

```fish
complete --no-files --command gifu --keep-order --arguments '(__fish_git_recent_commits)'
```

`__fish_git_recent_commits`とは`fish`側で定義されている、直近50件のコミット・ハッシュを取得するための関数です。
`fish`にはこのように便利な補完用の関数がいくつか用意されています。
[公式のドキュメントでもいくつか紹介されています](https://fishshell.com/docs/current/completions.html#useful-functions-for-writing-completions)が、自分でも使ってみたいと思ったり気になったりする補完方法があったらソース・コードを見て確認してみると良いでしょう。
![](/images/fish-completion-from-commit-message-003.gif)

ちゃんと`foo`だけを含むコミットだけが表示されていますね。
これでめでたく補完ができるようになりました！

