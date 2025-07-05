---
title: "Vim が Wayland の clipboard をサポート"
emoji: "🎉"
type: "tech"
topics: ['Vim', 'Wayland', 'クリップボード']
published: true
published_at: "2025-07-11 00:00"
publication_name: "vim_jp"
---
# Wayland の clipboard
Vim では、2025年6月27日更新の v9.1.1485 で、Wayland の clipboard のサポートが入りました。

最新の Vim をビルドすると`+wayland`と`+wayland_clipboard`が有効になっていると思います。
`:version`で確認してみてください。
逆に Wayland への接続を無効にしたい場合は`-Y`オプションを付けて Vim を起動します。また、Wayland への接続を再度初期化するコマンド`:wl[restore]`も追加されています。

これにより、今までは Wayland の clipboard と Vim を双方向で連携するには以下のような設定が必要でした。
(なお、Neovim であれば`g:clipboard`があるので、このようなワークアラウンドは元々不要でした。)
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

また、この設定の他にも clipboard と連携したいコマンドがある度に`setreg`を呼ぶ必要がありました。
しかし、これからは次の1行で双方向の連携ができるようになります。
```vim
set clipboard=unnamedplus
```

# 関連するオプションなど
## X11 と Wayland の両方が有効なときの優先順位
`'clipmethod'`オプションでどちらと優先するか指定することができます。デフォルトでは`"wayland,x11"`となっており、Wayland が優先されます。
現在指定されているメソッドは`v:clipmethod`で確認できます。

## Wayland seat の設定
もし、Wayland の同一セッション内で複数の seat を使用している場合は、新たに導入された`'wlseat'`で seat を指定できます。

## その他
GNOME などの環境では Wayland の clipboard にアクセスするのにフォーカスを奪う必要があります。その際に使用する`'wlsteal'`オプションが追加されました。
Wayland への接続や`'wlsteal'`が有効な時にフォーカスを奪う際のタイムアウト時間を指定する`'wltimeoutlen'`オプションが追加されました。

# おわり
Wayland に関する、最近追加された機能について概観していきました。
最新の情報については`:help wayland.txt`をご参照ください。
以上です！ ウェーイ！

