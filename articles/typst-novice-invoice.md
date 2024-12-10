---
title: "Typstに入門してみた話。請求書を作ってみた話。"
emoji: "💴"
type: "tech"
topics: [Typst]
published: true
published_at: "2024-12-10 00:00"
---
:::message
この記事は[Typst Advent Calendar 2024](https://qiita.com/advent-calendar/2024/typst)の 2024-12-10 の記事です。
前回は[清水団](https://zenn.dev/dannchu)さんの[Typst でLaTeXのtcolorbox.styみたいに箱を描きたい！](https://zenn.dev/dannchu/articles/1a0f81ee106758)です。
次回は[Omochice](https://zenn.dev/omochice)さんの[Typixを使って複数環境でTypstでスライドをコンパイルする](https://zenn.dev/omochice/articles/reproducible-compilation-of-typst-by-typix)です。
:::
------
Typst については以前から「なんか良さそう」と思ってはいたものの、なかなか手を出せずにいましたが、今回の Advent Calendar を書くことをきっかけに入門してみることにしました。
この記事では、ローカルでの環境構築から始まり、[チュートリアル](https://typst.app/docs/tutorial/)を読んで、簡単な請求書を作ってみた過程について記述します。

Typst については、[LaTeX ユーザ向けの手引き書](https://typst.app/docs/guides/guide-for-latex-users/)もあります。私の場合は、LaTeX の知識がすっかりエスケープしてしまったので、前提知識を必要としない[^tutorial][チュートリアル](https://typst.app/docs/tutorial/)を読み進めていきます。
:::message
ちなみに[公式](https://typst.app/legal/brand/)によると Typst は /taɪpst/ と発音するようです。
:::

## 環境構築
[チュートリアル](https://typst.app/docs/tutorial/)ではブラウザ上で編集・プレビューできる[typst.app](https://typst.app/)の使用を勧めていますが、私は手に馴染んだ Vim で作業をしたいのでローカルでの環境を整えていきます。
私が普段作業している環境は Arch Linux です。Arch Linux の公式パッケージには typst がありますので導入は簡単です。また、typst の変更を監視し hot-reload するための機能や LSP としての機能がある tinymist もインストールしておきます。
```shell
sudo pacman -S typst tinymist
```

なお、Vim や Neovim を使用して tinymist でプレビューを表示している場合は、Vim や Neovim のデフォルトの設定ではファイルの変更が認識されない不具合があります[^tinymist]。Workaround として、以下ののように Vim の設定ファイルに書き足しておきました。
```vim
augroup MyTypst
  autocmd!
  autocmd Filetype typst setlocal backupcopy=yes
augroup END
```

## Hello, World
Typst では markup などで書かれた表現のことを`content`と読んでいます[^content]。
例えば、次の align 関数を使った例では、`[Hello, World]`という`content`を引数に取って、右に`align`された Hello, World という`content`を出力します。
```typst
#align(
  right,
  [Hello, World]
)
```
![](/images/typst-novice-invoice-01.png)

また、引数の`content`だけを外に出す、次のような書き方もできます。
```typst
#align(right)[
  Hello, World
]
```
![](/images/typst-novice-invoice-01.png)

これらを見ると、設定が増えた時にどんどんネストが深くなっていって大変そうだなと思ったのですが、以下のような書き方も用意されています。
```typst
#set align(right)
Hello, World
```
![](/images/typst-novice-invoice-01.png)

次のように複数の設定を書くこともできます。
```typst
#set par(justify: true)
#set align(right)
Hello, World

#set par(justify: false)
#set align(left)
Good bye, World
```
![](/images/typst-novice-invoice-02.png)

この`set`による記述は、今後その関数を使う時のデフォルト引数を指定しておくという行為を概念化したものなのだそうです[^conceptualization]。
書きやすくなった反面、`content`が状態を持ってしまっているように見えて (パーサなどを書く時に特に) 大変そうだという感想を抱きました。

## スクリプト
Typst には、`Boolean`や`Integer`、`Floating-point number`、`String`の他に`Array`や`Dictionary`、`For loop`、`While loop`などをコード・ブロックに書くことができます[^script]。ここまで扱ってきた関数の呼び出しもコード・ブロックとして書かれています。
さて、`Array`に対しては、`map`関数なども用意されているので、請求書を作るくらいであれば十分そうです。
ということで、さくっと作ってみましょう。

## 請求書作ってみた
`let`で請求項目 (`Dictionary`) の配列を定義します。
```typst
#let items = (
  (
    name: "Service Foo",
    amount: 11,
    price: 100000,
  ),
  (
    name: "Service Bar",
    amount: 4,
    price: 300000,
  ),
)
```

`For loop`で加工して`table`関数の引数として渡してテーブルを作成します。`..`は`spreading operator`です[^spreading]。
```typst
#table(
  table.header(
    [詳細], [数量], [単価], [金額]
  ),
  ..for item in items {(
    item.name,
    [#{item.amount}個],
    [#{item.price}円],
    [#{item.amount * item.price}円],
  )}
)
```

合計金額も`map`関数と`sum`関数が組み込みで用意されているので気持ち良く書けました。
```typst
#let tax-rate = .1
#let total-price = items.map(it => it.price * it.amount).sum(default: 0)
#let tax = total-price * tax-rate
#let total = total-price + tax
```

### 完成！
組版マークアップ言語の記事なのに、肝心の組版部分がかなりやっつけになってしまいましたが、以下のように、土台としてはおよそ満足のいくものが簡単に作成できました。
![](/images/typst-novice-invoice-03.png)

```typst
#let date = (year: 2024, month: 12, day: 10)
#let serial = 1
#let document-number = [#date.year#date.month#{date.day}-#serial]
#let due-date = (year: 2024, month: 12, day: 31)
#let tax-rate = .1
#let items = (
  (
    name: "Service Foo",
    amount: 11,
    price: 100000,
  ),
  (
    name: "Service Bar",
    amount: 4,
    price: 300000,
  ),
)
#let total-price = items.map(it => it.price * it.amount).sum(default: 0)
#let tax = total-price * tax-rate
#let total = total-price + tax

= 請求書
#v(1em)
#grid(
  columns: (4fr, 3fr),
  {
    [Hoge Fuga 御中]
    v(.1em)
    [
      〒000-0000 \
      東京都hoge区fuga 1-1
    ]
    v(1em)
    [下記の通りご請求します。]
    table(
      columns: (auto, auto, auto),
      inset: (x: 1.5em, y: .5em),
      [小計],
      [消費税],
      [合計金額],
      [#total-price 円],
      [#tax 円],
      [#total 円],
    )
    v(1em)
    [
      振込期日: #{due-date.year}年#{due-date.month}月#{due-date.day}日 \
      振込先: 😄😄😄
    ]
  },
  {
    [
      日付: #{date.year}年#{date.month}月#{date.day}日 \
      請求書番号: #document-number
    ]
    v(1em)
    [NI57721]
    v(.1em)
    [
      〒000-0000 \
      東京都example区sample 1-1
    ]
  }
)

#table(
  columns: (1fr, auto, auto, auto),
  inset: (x: 1.5em, y: .5em),
  table.header(
    [ 詳細 ], [ 数量 ], [ 単価 ], [ 金額 ]
  ),
  ..for item in items {(
    item.name,
    [ #{item.amount}個 ],
    [ #{item.price}円 ],
    [ #{item.amount * item.price}円 ],
  )}
)
```

実際に上記のものを請求書として使用し続ける場合は、テンプレートとして作るのが良さそうです[^template]。
Typst のテンプレートとは、特定の範囲のドキュメントまるごと引数として渡せるような関数のようです。
この辺は、実際の作成されているテンプレートを見ながらコツを掴んでいきたいと思います。

今回の記事はここまでとなります！　ありがとうございました。

------
[^tutorial]: This tutorial does not assume prior knowledge of Typst, other markup languages, or programming. (https://typst.app/docs/tutorial/)

[^tinymist]: これは Vim や Neovim がファイルを保存する際に、デフォルトではファイルを上書きせずに新しいファイル作成して置き換えるという挙動をすることによるものです。この問題について詳しくは[該当する tinymist の issue](https://github.com/Myriad-Dreamin/tinymist/issues/580)をご覧ください。

[^content]: https://typst.app/docs/reference/foundations/content/

[^conceptualization]: https://typst.app/docs/tutorial/formatting/#set-rules

[^script]: 詳しくは https://typst.app/docs/reference/syntax/

[^spreading]: https://typst.app/docs/reference/foundations/arguments/#spreading

[^template]: テンプレートについてはチュートリアルに詳しいです https://typst.app/docs/tutorial/making-a-template/

