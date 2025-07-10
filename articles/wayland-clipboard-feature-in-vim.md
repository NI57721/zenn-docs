---
title: "Vim が Wayland のクリップボードをサポート"
emoji: "🎉"
type: "tech"
topics: ['Vim', 'Linux', 'Wayland', 'クリップボード']
published: true
published_at: "2025-07-11 00:00"
publication_name: "vim_jp"
---
:::message
この記事は[Vim駅伝](https://vim-jp.org/ekiden/)の 2025-07-11 の記事です。
:::
------
# Wayland のクリップボード
Vim では、2025年6月27日更新の [v9.1.1485](https://github.com/vim/vim/commit/b90c2395b2c055aed38e0c5fd40c1841f43dab4b) で、Wayland のクリップボードのサポートが入りました。

最新の Vim をビルドすると`+wayland`と`+wayland_clipboard`が有効になっていると思います。`:version`で確認してみてください。
Wayland への接続を無効化したい場合は`-Y`オプションを付けて Vim を起動する必要があります。Wayland への接続を再度初期化するコマンド`:wl[restore]`も追加されています。

今までは、Wayland のクリップボードと Vim のレジスタを双方向で連携する[^unnamedplus]には以下のような設定が必要でした。[^neovim]
この他にもヤンクが絡むコマンドなどがある度に`setreg`を呼ぶ必要がありました。
```vim
nnoremap <silent> p      <Cmd>call setreg('"', system('wl-paste -n'))<CR>""p
nnoremap <silent> P      <Cmd>call setreg('"', system('wl-paste -n'))<CR>""P
xnoremap <silent> p      <Cmd>call setreg('"', system('wl-paste -n'))<CR>""P
xnoremap <silent> P      <Cmd>call setreg('"', system('wl-paste -n'))<CR>""p
inoremap          <C-R>" <Cmd>call setreg('"', system('wl-paste -n'))<CR><C-R>"

set clipboard^=unnamed

augroup WaylandClipboard
  autocmd!
  autocmd TextYankPost * silent call job_start(['wl-copy', '--', getreg('*')])
augroup END
```

これからは、上記のケースでは次の1行で済むようになります。
```vim
set clipboard^=unnamedplus
```

# 関連するオプションなど
## X11 と Wayland の両方が有効な時の優先順位
`'clipmethod'`オプションでどちらを優先するか指定することができます。デフォルトでは`"wayland,x11"`となっており、Wayland が優先されます。
現在指定されているメソッドは`v:clipmethod`で確認できます。

## Wayland seat の設定
もし、Wayland の同一セッション内で複数の seat を使用している場合は、新たに導入された`'wlseat'`で seat を指定できます。

## その他
GNOME では Wayland のクリップボードにアクセスする為にフォーカスを奪う必要があります。その際に使用する`'wlsteal'`オプションが追加されました。
更に、Wayland への接続や`'wlsteal'`が有効な時にフォーカスを奪う際のタイムアウト時間を指定する`'wltimeoutlen'`オプションが追加されました。

# おわり
Wayland に関する、最近追加された機能についてまとめてみました。
最新の情報については`:help wayland.txt`をご参照ください。
以上です！ ウェーイ！

------
[^unnamedplus]: ここでは clipboard^=unnamedplus 相当のことをさせています。
[^neovim]: Neovim であれば`g:clipboard`があるので、このようなワークアラウンドは元々不要です。

