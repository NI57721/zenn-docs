---
title: "長文丸暗記用のVimプラグインを作った話"
emoji: "🌊"
type: "tech" # tech: 技術記事 / idea: アイデア
topics: ["vim", "neovim"]
published: true
published_at: "2023-12-08 18:00"
publication_name: "vim_jp"
---
:::message
この記事は[Vim Advent Calendar 2023](https://qiita.com/advent-calendar/2023/vim)の8日目の記事です。
:::
------
みなさん、暗記は好きですか？　私も好きです。
Vim ももちろん大好きですよね。
そんなみなさんの為のプラグインを作りました。
その名も shakyo(写経) です。
私自身が趣味で行っている洋書の丸暗記に使っていた機能をプラグインにしました。
https://github.com/NI57721/vim-shakyo
![](/images/vim-shakyo.gif)

# 基本動作
上の GIF 画像を見ると雰囲気が掴みやすいと思います。
任意のバッファーで`<Plug>(shakyo-run)`を実行すると shakyo モードが始まります。shakyo モードではカレント行以降が消えた状態のバッファーに移るので、そこから続きを淡々と入力していきます。1行正しく入力できれば行末に印が付きます。間違えた箇所はハイライトされます。

# ヒント機能
詰まってしまった時には、`<Plug>(shakyo-clue)`でヒントを得ることができます。
`{count}`にも対応しています。そして地味ながら苦労した箇所なのですが、ドット・リピートにも対応しています。
色々試してみたところ、あまり覚えていない文章で始める時はヒント機能をどんどん使っていった方が暗記しやすかったです。

# 使い方
vimrcに以下のようなマッピングを設定しておくと良いでしょう。
`<Plug>(shakyo-clue)`は shakyo モードを抜けて元のバッファーに戻ります。
```vim:vimrc
nnoremap <leader>r <Plug>(shakyo-run)
nnoremap <leader>q <Plug>(shakyo-quit)
nnoremap <leader>c <Plug>(shakyo-clue)
```

# 設定
正解入力完了時・誤入力時のハイライト・グループを設定できるようにしています。デフォルトでは以下の設定と同等のものになっています。
```vim:vimrc
call shakyo#config(#{
  \   highlight: #{
  \     completed: 'WildMenu',
  \     wrong: 'ErrorMsg'
  \   }
  \ })
```

# 頑張ったポイント
先述のドット・リピートには苦心しました。助言をくれた[vim-jp](https://vim-jp.org/docs/chat.html)のみなさんありがとうございました。
また、今回はテストを意識した実装にしています。[themis](https://github.com/thinca/vim-themis)でのカバレッジが90%くらいあるのも頑張りポイントでした。

# これから増やしたい機能
特定の文字があってもなくても正しいとする機能を足したいと思っています。
また、表記揺れに対応できる機能も欲しいと思っています。
例えば color と colour、gray と grey、御座候・今川焼き・大判焼き[^jk]、どれで入力しても正しいとする機能です。
時間を見付けながら実装していきたいと思います。

# おわり
Happy Vimming!

------
[^jk]: これは表記揺れとは違いますが。
