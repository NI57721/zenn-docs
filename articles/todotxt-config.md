---
title: "Todo.txt の状態ファイルや設定ファイルのパスを変える"
emoji: "✅"
type: "tech" # tech: 技術記事 / idea: アイデア
topics: [todotxt, タスク管理, shell, CLI]
published: true
published_at: "2023-09-01 18:00"
---
# TL;DR
`/etc/todo/config`を読めば大体オーケー。
https://github.com/todotxt/todo.txt-cli/blob/master/todo.cfg

# Todo.txt とは？
Todo という名前のテキスト・ファイルではありません。「Todo.txt」という名前のシェル上で動作するタスク管理アプリです。
必要な機能だけがあるシンプルな実装。便利です。
使い方についてはこちらの記事が分かりやすいと思いました。
https://zenn.dev/zakkie/articles/e050332ca490a8

詳しくは公式サイトやリポジトリをご覧ください。
http://todotxt.org/
https://github.com/todotxt/todo.txt-cli

# 環境
使用している Todo.txt は以下の通りです。
バージョンが`v@DEV_VERSION@`となっていますが、aur にあるバージョン`2.12.0`のものを使っています。
```
$ todo.sh -V
TODO.TXT Command Line Interface v@DEV_VERSION@

Homepage: http://todotxt.org
Code repository: https://github.com/todotxt/todo.txt-cli/
Contributors: https://github.com/todotxt/todo.txt-cli/graphs/contributors
License: https://github.com/todotxt/todo.txt-cli/blob/master/LICENSE
$ paru -Q | grep todotxt
todotxt 2.12.0.post2-2
```

# この記事の動機
ホーム・ディレクトリを XDG Base Directory specification に則って整理していた時に、Todo.txt の管理に少し手間取りました。そこでソースを直に見ていくつかの知見を得たので情報を共有したいと思います(主に未来の自分へ)。

# 設定ファイルの場所を変更する
`$ todo.sh help`に情報があります。
```
    -d CONFIG_FILE
        Use a configuration file other than one of the defaults:
          /home/[ユーザー名]/.todo/config
          /home/[ユーザー名]/todo.cfg
          /home/[ユーザー名]/.todo.cfg
          /home/[ユーザー名]/.config/todo/config
          /usr/bin/todo.cfg
          /etc/todo/config
```

上記の内容を少し補足すると以下の順に探索し、存在したファイルを設定ファイルとして使用します。
- `$HOME/.todo/config`
- `$HOME/todo.cfg`
- `$HOME/.todo.cfg`
- `${XDG_CONFIG_HOME:-$HOME/.config}/todo/config`
- `$(dirname "$0")/todo.cfg`
- `${TODOTXT_GLOBAL_CFG_FILE:-/etc/todo/config}`

# 状態ファイルの場所を変更する
タスクの進捗や履歴などは、デフォルトで`$HOME/.todo`に保存されます。
これを変更するには設定ファイルで指定する必要があります。
詳しくは`/etc/todo/config`に書いてあります。
私の場合、設定ファイル(`$XDG_CONFIG_HOME/todo/config`)内に`export TODO_DIR=$XDG_STATE_HOME/todo`とだけ指定しています。
```bash
# Your todo.txt directory (this should be an absolute path)
#export TODO_DIR="/Users/gina/Documents/todo"
export TODO_DIR=~/.todo

# Your todo/done/report.txt locations
export TODO_FILE="$TODO_DIR/todo.txt"
export DONE_FILE="$TODO_DIR/done.txt"
export REPORT_FILE="$TODO_DIR/report.txt"
```

この他、`/etc/todo/config`には、カラー情報やタスクの表示順、タスクを表示する際のフィルターの設定方法について書いてあります。

# 終わり
良いツールなので是非使ってみてください！

