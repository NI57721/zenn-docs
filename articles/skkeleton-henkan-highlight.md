---
title: "【さらば▽】SKKで変換中の文字にVimのハイライトを付ける【skkeleton】"
emoji: "🔦"
type: "tech"
topics: [Vim, Neovim, SKK, skkeleton]
published: true
published_at: "2025-09-26 00:00"
publication_name: "vim_jp"
---
:::message
この記事は[Vim駅伝](https://vim-jp.org/ekiden/)の2025-09-26の記事です。
:::
------
Vim / Neovim での日本語の入力に [skkeleton](https://github.com/vim-skk/skkeleton) を使用している際に、変換中の文字にハイライトを提供する Vim プラグインを作成しました。
https://github.com/NI57721/skkeleton-henkan-highlight/
実際の使用風景はこちらをご覧ください。
![](/images/skkeleton-henkan-highlight-01.gif)

# skkeleton とは
[skkeleton](https://github.com/vim-skk/skkeleton) とは SKK で日本語を入力する為の Vim / Neovim のプラグインです。

# SKK とは
日本語入力システムの一です。
MS-IME や ATOK とは異り、漢字に変換する区切りをユーザーが決める必要があるという特徴があります。
SKK については以下の記事に詳しくあります。
[かな漢字変換プログラム SKK の紹介 | Emacs JP](https://emacs-jp.github.io/tips/skk-intro)
[SKKとは (エスケイケイとは) [単語記事] - ニコニコ大百科](https://dic.nicovideo.jp/a/skk)

# ハイライトの付け方
<https://github.com/NI57721/skkeleton-henkan-highlight/>では SkkeletonHenkan という Vim のハイライト・グループを提供しているので、こちらに設定を加えることで変換中の文字をハイライトすることができます。
動作している様子は冒頭の GIF アニメーションをご覧ください。
私は以下の設定で下線だけ表示するようにしています。
```vim
highlight SkkeletonHenkan cterm=underline
```
ハイライトの設定方法は`:help :highlight`をご覧ください。太字にしたり、イタリックにしたり、前景や後景にだけ色を付けたり、文字色と背景色を反転させたりと色々できます。

# さらば▽
SKK といえば、変換時に現れる「▽」が何とも愛らしいですよね。[^noproblem]
ところが、以下に紹介する、skkeleton の状態をポップアップで表示する弊プラグインと併せて今回のプラグインを使用すると、「▽」を非表示にしても差し支え無く入力ができるようになります。[^noproblem]
https://github.com/NI57721/skkeleton-state-popup
![](/images/skkeleton-henkan-highlight-02.gif)

以上です。
それでは、よい SKK ライフを！

------
[^noproblem]: 私の感想です。

