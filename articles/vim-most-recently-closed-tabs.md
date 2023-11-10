---
title: "Vimで最近閉じたファイルを開こう"
emoji: "📑"
type: "tech" # tech: 技術記事 / idea: アイデア
topics: ["vim", "neovim"]
published: true
published_at: "2023-11-10 09:00"
publication_name: "vim_jp"
---
:::message
この記事は[Vim駅伝](https://vim-jp.org/ekiden/)の2023-11-10の記事です。
:::
------
# Vim のタブ機能
Vim でたくさんのファイルを閲覧したい時、みなさんはどうしますか？　バッファーに開いておいて切り替える人もいれば、タブをたくさん開いて順繰り見ていく人もいるかと思います。私は後者のタブ派です。
例えば、git で管理しているファイルをパーっと概観したくなった時には
```shell
vim -p $(git ls-files)
```
と実行すれば Vim のタブで全て開くことができます。[^p-opt]
このような使い方をしていると、うっかり必要なタブを閉じてしまったりすることがあるんです。そんな時に便利な機能を作ってみました。
![](/images/vim-most-recently-closed-tabs.gif)

# 閉じたタブの管理
## まずはコード
```vim
nnoremap <leader>p <Cmd>call ShowMostRecentlyClosedTabs()<CR>
noremap  <C-Up>    :if len(g:most_recently_closed) > 0 \|
                     \   execute ':tabnew ' .. remove(g:most_recently_closed, 0) \|
                     \ endif<CR>

if !exists('g:most_recently_closed')
  let g:most_recently_closed = []
endif

augroup MostRecentlyClosedTabs
  autocmd!
  autocmd BufWinLeave * if expand('<amatch>') != '' | call insert(g:most_recently_closed, expand('<amatch>')) | endif
augroup END

function! ShowMostRecentlyClosedTabs() abort
  new
  set bufhidden=hide
  call append(0, g:most_recently_closed)
  $delete
  autocmd WinClosed <buffer> bwipeout!
  nnoremap <buffer> q <Cmd>bwipeout!<CR>
  nnoremap <buffer> <ESC> <Cmd>bwipeout!<CR>
  nnoremap <buffer> dd <Cmd>call remove(g:most_recently_closed, line('.') - 1) | delete<CR>
  nnoremap <buffer> <CR> <Cmd>execute 'tabnew ' .. remove(g:most_recently_closed, line('.') - 1)<CR>
endfunction
```

## 何してるの？
```vim
  autocmd BufWinLeave * if expand('<amatch>') != '' | call insert(g:most_recently_closed, expand('<amatch>')) | endif
```
↑の処理で、ウィンドウからバッファーが削除される時に、そのファイル名を`g:most_recently_closed`に追加しています。

```vim
noremap  <C-Up>    :if len(g:most_recently_closed) > 0 \|
                     \   execute ':tabnew ' .. remove(g:most_recently_closed, 0) \|
                     \ endif<CR>
```
そして、直近に閉じたファイル名を`g:most_recently_closed`から取得して新しいタブで開くようにマッピングしています。
これだけで、「間違って閉じちゃった！」という時に即座に開きなおすことができます。

おまけで`ShowMostRecentlyClosedTabs()`という関数を定義しました。この関数を実行すると`g:most_recently_closed`を新しいバッファーで開いて、`g:most_recently_closed`の任意のパスを削除したり任意のパスに移動したりできるようにしています。[^for-simplicity](冒頭の gif を参照)

# おまけ
私のタブ関連のキーバインド。
よくタブを開くのでタブの操作に関する設定が多くなっています。
```vim
noremap <Tab>     <Cmd>tabnext<CR><C-G>
noremap <S-Tab>   <Cmd>tabprevious<CR><C-G>
noremap <C-Right> <Cmd>tabnext<CR><C-G>
noremap <C-Left>  <Cmd>tabprevious<CR><C-G>
noremap <C-Up>    <Cmd>if len(g:most_recently_closed) > 0 \|
                    \   execute ':tabnew ' .. remove(g:most_recently_closed, 0) \|
                    \ endif<CR>
noremap  <C-Down> <Cmd>q<CR><C-G>
noremap  <expr> <C-lt> ':tabmove -' .. v:count1 .. '<CR>'
noremap  <expr> <C->>  ':tabmove +' .. v:count1 .. '<CR>'
nnoremap gr        <Cmd>tabnext<CR><C-G>
nnoremap gR        <Cmd>tabprevious<CR><C-G>

" 変更の無いタブとウィンドウを全て閉じる
cabbr qa tabdo windo if !&modified \| try \| close \| catch \| quit \| endtry \| endif

" 開いているタブとウィンドウを問答無用で閉じる
cabbr qq tabdo windo try \| close \| catch \| quit! \| endtry
```

# おわり
それでは良い Vim ライフを！

------
[^p-opt]: Vim はデフォルトで、タブの最大数が 10 に設定されています。タブを大量に開きたい場合は、vimrc で`set tabpagemax=255`などと大き目の上限を設定しましょう。
[^for-simplicity]: 簡易的な実装の為、パスに改行を含む場合などには対応していません。

