---
title: "思考の速さで日本語入力したい【Neo AZIK】"
emoji: "🏁"
type: "tech" # tech: 技術記事 / idea: アイデア
topics: ["skk", "azik", "vim", "skkeleton"]
published: true
published_at: "2024-12-30 00:00"
publication_name: "vim_jp"
---
:::message
この記事は[Vim駅伝](https://vim-jp.org/ekiden/)の2024-12-30の記事です。
:::
------
この記事では、ローマ字入力の拡張の一である AZIK に対して、その AZIK を更に拡張させより効率的に日本語を入力できないか考察していきます。
そして、考案した方法で Vim から日本語を入力できるようにします。

こちらが今回考案した方法で入力している様子です。
画像の下に表示されているキー・ストロークも併せてご覧ください。
![](/images/neo-azik-for-you-demo.gif)

AZIK について詳しくは、考案者である木村 清氏のウェブ・ページをご覧ください。
[AZIK総合解説書](https://web.archive.org/web/20240720205500/http://hp.vector.co.jp/authors/VA002116/azik/azikinfo.htm) ※Internet Archive へのリンクです。

ローマ字入力から段階的に移行できるので、まだやってみたことがないという方は是非試してみてください！
AZIK の実際の運用方法については、私の過去の記事が参考になるかもしれません。
https://zenn.dev/vim_jp/articles/my-azik-is-burning

ここからは、AZIK について基本的な理解があることを前提に書いていきます。

# こうなった！
まず結果を置いておきます。
子音
![](/images/neo-azik-for-you-consonants.png)
二重母音などのシーケンス[^sequences]
![](/images/neo-azik-for-you-sequences.png)

では、ここに至る経緯について説明していきます。

# AZIK の可能性
AZIK では`p`は ou というシーケンスに相当しているので、`gp`と打つことで「ごう」と入力できます。一方で、`gm`と打っても何も入力できません。全てのキーに対して何らかのシーケンスを登録すれば日本語の入力効率が上がるのではないか、というのが今回のメイン・テーマです。
また、QWERTY 配列では`v`などの日本語入力では出現頻度の低い子音が贅沢な位置に配置されています。これらに対して、「ヴァ行」などの代わりに他の子音を割り当てて効率化を図りたいと思います。
以上の2点について AZIK を拡張していきます。ローマ字入力との互換性は考慮しません。

# 日本語における出現頻度
出現頻度の高い文字を新たに採用していきたいというわけなので、まず日本語における母音や子音、そして母音と子音の組み合わせの頻度を調べていきます。
日本語のサンプルとして [Wikipedia の秀逸な記事](https://ja.wikipedia.org/wiki/Wikipedia:%E7%A7%80%E9%80%B8%E3%81%AA%E8%A8%98%E4%BA%8B)内の全ての記事 (丁度100件あります) を分析します。また、Wikipedia の文章は常体 (だ・である体) であるため、敬体 (です・ます体) のサンプルとして [Vim 駅伝](https://vim-jp.org/ekiden/) の記事から敬体で書かれた Zenn の記事 161件[^honorific]を分析します[^zenn]。
なお、私は外来語の入力は abbrev モードですることが殆どのため、今回の分析からはカタカナで終わる単語を除外しています[^exclusion]。

日本語の解析には [MeCab](https://taku910.github.io/mecab/) を用いました。分析内容については後述します。分析に用いたスクリプトはこちらです。
https://github.com/NI57721/analysis-of-japanese-words-for-azik
Wikipedia の記事の分析結果はこちら:
https://gist.github.com/NI57721/2facb3227fa009c7d51e23710a2dc125
Vim 駅伝の記事の分析結果はこちら:
https://gist.github.com/NI57721/63eab2ddf9a0f4fa40e77c717eff84ce

# 子音の割り当て
子音の出現頻度について調べます。

## 子音の出現頻度
`t`はタ行を表しています。「つ」もタ行に含みます。
一方`ts`はツァ行です。「つ」はツァ行に含めていません。
「し」などについても同様です。
また、`N`は「ん」を、`L`は「っ」をそれぞれ表します。

Wikipedia 内の子音の出現回数。
![](/images/neo-azik-for-you-chart1.png)
```json
[
  ["k",  492273],
  ["t",  433845],
  ["s",  389207],
  ["n",  332822],
  ["y",  260506],
  ["N",  259349],
  ["r",  223205],
  ["h",  162542],
  ["m",  142812],
  ["g",  134430],
  ["z",  107859],
  ["w",  77899],
  ["sy", 75844],
  ["b",  69971],
  ["L",  59361],
  ["zy", 30565],
  ["ky", 28907],
  ["ty", 21665],
  ["p",  14744],
  ["hy", 4957],
  ["gy", 4251],
  ["by", 3072],
  ["ny", 2249],
  ["py", 608],
  ["my", 607],
  ["f",  52],
  ["v",  16],
  ["ts", 0]
]
```

Vim 駅伝内の子音の出現回数。
![](/images/neo-azik-for-you-chart2.png)
```json
[
  ["k",  30430],
  ["t",  30093],
  ["s",  29519],
  ["n",  25394],
  ["r",  17605],
  ["m",  13907],
  ["y",  11963],
  ["h",  10605],
  ["N",  10281],
  ["w",  8395],
  ["g",  7727],
  ["z",  7044],
  ["L",  4500],
  ["b",  3207],
  ["sy", 2343],
  ["zy", 1222],
  ["ky", 668],
  ["ty", 648],
  ["hy", 511],
  ["ny", 491],
  ["gy", 162],
  ["p",  157],
  ["by", 36],
  ["my", 17],
  ["py", 7],
  ["ts", 0],
  ["f",  0],
  ["v",  0]
]
```

## キーの割り当て
以上の結果を見てみると、ヒャ行、キャ行、ギャ行にキーを割り当ててみるのが良さそうです。
そこで、`Q`をギャ行に、`F`をヒャ行に、`V`をキャ行に割り当ててみました[^azik-q]。
また、ローマ字入力では`sha`で「しゃ」、`thi`で「てぃ」などと入力できることが多いですが、この後で全てのキーにシーケンスを登録したいので、特殊な子音を入力する為のキーを`G`に限定します。
結果として、次のようになりました。
![](/images/neo-azik-for-you-consonants.png)

また、図に無い子音は次のように割り当てています。
| キー | 割り当て | キー | 割り当て | キー | 割り当て |
| ---- | ---- | ---- | ---- | ---- | ---- |
| WG | ウァ行 | RG | リャ行 | TG | テャ行 |
| PG | ピャ行 | FG | ファ行 | VG | ヴァ行 |
| ZG | ツァ行 | DG | ヂャ行 | NG | ニャ行 |
| MG | ミャ行 | BG | ビャ行 |

# シーケンスの割り当て
次に母音・子音・母音の組み合わせの頻度を調べてみます。
例えば「ウ段 + る」という組み合わせが多いと分かれば`uru`というシーケンスに対応するキーを用意すれば良さそうだということになります。
なお、組み合わせを分析する際に名詞の後と文節で区切ることにしました。「雪が白い」という文があった場合、「雪」「が」「白い」と一旦分けてから集計します。というのも、`iga`というシーケンスの為のキーが存在したとしても「雪が」と入力する際にそれを用いることはほぼ無いためです[^analysis]。

## 母音・子音・母音の出現頻度
Wikipedia と Vim 駅伝の記事について、それぞれ上位30の組み合わせを見てみましょう[^result]。
敬体と常体で差が出ているのが面白いですね。

Wikipedia 内の子音の出現回数。
```json
[
  ["ou",  193567],
  ["ai",  85390],
  ["ei",  68047],
  ["uu",  53279],
  ["aku", 38931],
  ["oku", 36419],
  ["ita", 21369],
  ["ite", 20563],
  ["oto", 17460],
  ["ara", 17166],
  ["ono", 17121],
  ["etu", 16475],
  ["uru", 16278],
  ["aka", 15439],
  ["uki", 14716],
  ["eki", 14344],
  ["ata", 13779],
  ["itu", 13670],
  ["awa", 13511],
  ["ui",  13351],
  ["osi", 13227],
  ["eta", 12943],
  ["ete", 12397],
  ["eru", 11792],
  ["atu", 11373],
  ["ika", 11022],
  ["asi", 10836],
  ["ari", 9590],
  ["aga", 9505],
  ["iti", 9420],
  ...
]
```

Vim 駅伝内の子音の出現回数。
```json
[
  ["ou",   10235],
  ["ai",   5801],
  ["asu",  3581],
  ["ei",   3306],
  ["ima",  3014],
  ["ite",  2932],
  ["uru",  2531],
  ["uu",   2298],
  ["ita",  2255],
  ["aku",  2214],
  ["oto",  1607],
  ["oku",  1464],
  ["ono",  1450],
  ["uka",  1417],
  ["asi",  1399],
  ["oi",   1337],
  ["ara",  1241],
  ["ari",  1213],
  ["eLte", 950],
  ["eru",  944],
  ["ete",  939],
  ["ika",  887],
  ["uto",  853],
  ["ae",   848],
  ["ata",  797],
  ["izi",  794],
  ["ame",  788],
  ["ore",  786],
  ["iyo",  775],
  ["aLte", 765],
  ...
]
```

## シーケンスの選定
選定する際には、実際に使ってみてしっくりくるか確認してみるという温かみのある作業を数ヶ月程してきました。
敬体にある`asu`などはほぼ「ます」でしか使わないので`asu`というシーケンス用のキーを用意せず「ます」だけを単体で用意しておく、などの調整が必要でした。
数字にまでシーケンスを割り当てるのはやりすぎかとも思ったのですが、子音の後に打つキーですので干渉することがありません。どんどん登録していきましょう。
頻度の高いものを打ちやすい位置に配置したり、シーケンスから連想しやすい位置に配置したりと、試行錯誤のしがいがあります。
結果、このように落ち着きました。
![](/images/neo-azik-for-you-sequences.png)

`;`は SKK の sticky key に、`'`はカタカナ・モードに割り当てており、シーケンスは登録していません。

# 特殊拡張
AZIK には特殊拡張といって`kt`で「こと」などと入力できるようになっています。
独自に拡張したことにより、AZIK の特殊拡張は使わなくなりました。代わりに以下のものを登録していますが、なかなか便利です。`dv`はもともと「ぢて」というほぼ使わないような組み合わせなので上書きしてしまって問題ありません。
| キー | 割り当て | キー | 割り当て |
| ---- | ---- | ---- | ---- |
| jsn| ません | ds | です |
| js | ます | dv | でして |
| jg | ました | dg | でした |
| jv | まして |

`V`が`ite`、`G`が`ita`というシーケンスにしているので覚えやすく気に入っています。
他にも使わない子音とシーケンスの組み合わせは結構あるので、そこを有効活用するのは良いかもしれません。

# Vim での設定
Vim での日本語の入力には [skkeleton](https://github.com/vim-skk/skkeleton) を使用しています。
独自の AZIK を試してみたい場合はかなテーブルを作成する必要があり、`V`が`ite`というシーケンスなら`sv`で「して」、`kv`で「きて」などなど全て登録する必要があるのですが、これを自動で生成する関数を作りました。
この機能はプラグインにする予定ですのでしばらくお待ちを！[^plugin]
以下のように子音とシーケンス (コードでは combination となっています) を指定するだけで、気軽にいろいろ試せるようになっています。
また、例えば、`R`を`uru`というシーケンスにしている場合は`KR`で「く*る」というようにシーケンスの途中で変換できるようにもしてあります。

```vim
let s:kanatable =  s:createKanatable(#{
  \   combinations: {
  \     '1': 'e;te',
  \     '2': 'a;te',
  \     '3': 'aiq',
  \     '4': 'iru',
  \     '5': 'osi',
  \     '6': 'uka',
  \     '7': 'uto',
  \     '8': 'asi',
  \     '9': 'ari',
  \     '0': 'ana',
  [...]
  \   },
  \   consonants: {
  \     'q':  'gy',
  \     'w':  'w',
  \     'wg': 'wh',
  \     'r':  'r',
  \     't':  't',
  \     'y':  'y',
  \     'p':  'p',
  \     's':  's',
  \     'd':  'd',
  \     'f':  'hy',
  [...]
  \   },
  \   others: {
  \     'xtu': 'l',
  \     'n':   'nn',
  \   },
  \ })
```

関数はこちら
```vim
function s:mapAzikOkuri(input, feed) abort
  let input = substitute(a:input, '|', '\\|', 'g')
  for mode in ['i', 'c']
    execute 'autocmd User skkeleton-enable-post ' .. mode .. 'map <buffer> ' ..
      \   input .. " <Cmd>call <SID>azikOkuri('" .. input .. "', '" ..
      \   a:feed .. "')<CR>"
    execute 'autocmd User skkeleton-disable-post silent! ' .. mode ..
      \   'unmap <buffer> ' .. input
  endfor
endfunction

function s:azikOkuri(input, feed) abort
  if g:skkeleton#state.phase ==# 'input:okurinasi' && g:skkeleton#mode !=# 'abbrev'
    \   && g:skkeleton#vim_status().prevInput =~# '\a$'
    call skkeleton#handle('handleKey', #{key: split(a:feed, '\zs')})
  else
    call skkeleton#handle('handleKey', #{key: a:input})
  endif
endfunction

function! s:createKanatable(arg) abort
  let shift = {
    \   '1': '!',
    \   '2': '@',
    \   '3': '#',
    \   '4': '$',
    \   '5': '%',
    \   '6': '^',
    \   '7': '&',
    \   '8': '*',
    \   '9': '(',
    \   '0': ')',
    \   '-': '_',
    \   '=': '+',
    \   '\': '|',
    \   '`': '~',
    \   '[': '{',
    \   ']': '}',
    \   ';': ':',
    \   ',': '<',
    \   '.': '>',
    \   '/': '?',
    \ }
  let result = {
    \   'a':   ['あ', ''],
    \   'i':   ['い', ''],
    \   'u':   ['う', ''],
    \   'e':   ['え', ''],
    \   'o':   ['お', ''],
    \   ';':   ['っ', ''],
    \   'n':   ['ん', ''],
    \ }
  for combKey in keys(a:arg.combinations)
    let combination = a:arg.combinations[combKey]
    if combKey =~# '[a-z]'
      let keyWithShift = substitute(combKey, '.', '\u&', '')
    elseif has_key(shift, combKey)
      let keyWithShift = shift[combKey]
    else
      let keyWithShift = v:null
    endif
    if keyWithShift isnot v:null
      let s = substitute(combination, ';', a:arg.others['xtu'], 'g')
      let s = substitute(s, 'q', a:arg.others['n'], 'g')
      call s:mapAzikOkuri(keyWithShift, substitute(s, '\v^(.)(.)', '\1\u\2', ''))
    endif
    for consKey in keys(a:arg.consonants)
      let consonant = a:arg.consonants[consKey]
      let result[consKey .. combKey] = [s:convertToHiragana(consonant .. combination), '']
      if consKey !~# '[a-z]'
        let result[consKey .. shift[combKey]] = [s:convertToHiragana(consonant .. combination), '']
      endif
    endfor
  endfor
  return result
endfunction

function! s:convertToHiragana(str) abort
  let vowel_order = #{a: 0, i: 1, u: 2, e: 3, o: 4}
  let vowels = ['あ', 'い', 'う', 'え', 'お']
  let columns = #{
    \   k:  ['か', 'き', 'く', 'け', 'こ'],
    \   ky: ['きゃ', 'き', 'きゅ', 'きぇ', 'きょ'],
    \   g:  ['が', 'ぎ', 'ぐ', 'げ', 'ご'],
    \   gy: ['ぎゃ', 'ぎ', 'ぎゅ', 'ぎぇ', 'ぎょ'],
    \   s:  ['さ', 'し', 'す', 'せ', 'そ'],
    \   sy: ['しゃ', 'し', 'しゅ', 'しぇ', 'しょ'],
    \   z:  ['ざ', 'じ', 'ず', 'ぜ', 'ぞ'],
    \   zy: ['じゃ', 'じ', 'じゅ', 'じぇ', 'じょ'],
    \   t:  ['た', 'ち', 'つ', 'て', 'と'],
    \   ts: ['つぁ', 'つぃ', 'つ', 'つぇ', 'つぉ'],
    \   ty: ['ちゃ', 'ち', 'ちゅ', 'ちぇ', 'ちょ'],
    \   th: ['てゃ', 'てぃ', 'てゅ', 'てぇ', 'てょ'],
    \   d:  ['だ', 'ぢ', 'づ', 'で', 'ど'],
    \   dy: ['ぢゃ', 'ぢ', 'ぢゅ', 'ぢぇ', 'ぢょ'],
    \   dh: ['でゃ', 'でぃ', 'でゅ', 'でぇ', 'でょ'],
    \   n:  ['な', 'に', 'ぬ', 'ね', 'の'],
    \   ny: ['にゃ', 'に', 'にゅ', 'にぇ', 'にょ'],
    \   h:  ['は', 'ひ', 'ふ', 'へ', 'ほ'],
    \   hy: ['ひゃ', 'ひ', 'ひゅ', 'ひぇ', 'ひょ'],
    \   f:  ['ふぁ', 'ふぃ', 'ふ', 'ふぇ', 'ふぉ'],
    \   b:  ['ば', 'び', 'ぶ', 'べ', 'ぼ'],
    \   by: ['びゃ', 'び', 'びゅ', 'びぇ', 'びょ'],
    \   v:  ['ゔぁ', 'ゔぃ', 'ゔ', 'ゔぇ', 'ゔぉ'],
    \   p:  ['ぱ', 'ぴ', 'ぷ', 'ぺ', 'ぽ'],
    \   py: ['ぴゃ', 'ぴ', 'ぴゅ', 'ぴぇ', 'ぴょ'],
    \   m:  ['ま', 'み', 'む', 'め', 'も'],
    \   my: ['みゃ', 'み', 'みゅ', 'みぇ', 'みょ'],
    \   y:  ['や', 'い', 'ゆ', 'いぇ', 'よ'],
    \   r:  ['ら', 'り', 'る', 'れ', 'ろ'],
    \   ry: ['りゃ', 'り', 'りゅ', 'りぇ', 'りょ'],
    \   w:  ['わ', 'うぃ', 'う', 'うぇ', 'を'],
    \   wh: ['うぁ', 'うぃ', 'う', 'うぇ', 'うぉ'],
    \ }
  let phonemes = split(a:str, '\v([aiueo;q]|[^aiueo;q]+)\zs')

  let result = ''
  let i = 0
  while i < len(phonemes)
    let phoneme = phonemes[i]
    if phoneme == ';'
      let result ..= 'っ'
    elseif phoneme == 'q'
      let result ..= 'ん'
    elseif phoneme =~# '[aiueo]'
      let result ..= vowels[vowel_order[phoneme]]
    else
      let i += 1
      let vowel = phonemes[i]
      let result ..= columns[phoneme][vowel_order[vowel]]
    endif
    let i += 1
  endwhile
  return result
endfunction
```

# 3ヶ月くらい使ってみての感想
数字のキーに割り当てているシーケンス以外は使いこなせています。さくさく入力できていて大満足！　一方で数字のキーで自分が使いこなせているのは`4`に割り当てた`iru`くらいです。数字キーには必然的に頻度が低めのシーケンスが割り当てられている都合、なかなか記憶に定着しないのですよね。有効な活用法について、もう少し考えてみても良いかもしれません。
新しい子音については、すぐ慣れるしかなり楽だしで良いことしかありませんでした。全部やるのが大変そうという方でも、子音だけでも登録してみると良いかもしれません。

------
[^sequences]: 図中の`L`は「っ」を表します。
[^honorific]: 記事執筆時の2024年12月30日時点での数字です。
[^zenn]: プラットフォームを限定している理由は、Vim 駅伝の記事の多くが Zenn に投稿されているからということと、HTML の解析の手間を省くためです。
[^exclusion]: 例えば、「タンパク質」は分析に含みますが「テキスト・エディタ」は含みません。
[^azik-q]: `Q`は AZIK では「ん」に割り当てられています。代わりに単体の「ん」は`nn`と入力することにしています。また、`fu`だけは「ふ」にしています。
[^analysis]: 厳密に調査する場合は、「積雪」という単語について`ise`というシーケンスはカウントしないなど、もう少し細かく調整する必要があるでしょう。
[^result]: 全ての結果を知りたい方は、以下の vowel_combination を見てください。
Wikipedia はこちら: https://gist.github.com/NI57721/2facb3227fa009c7d51e23710a2dc125
Vim 駅伝はこちら: https://gist.github.com/NI57721/63eab2ddf9a0f4fa40e77c717eff84ce
[^plugin]: 毎回テーブルを生成しないでキャッシュするようにもしたいと思っています。

