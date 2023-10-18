---
title: "Goの標準ライブラリだけでX(旧Twitter)みたいなアプリを作ってみよう"
emoji: "🐦"
type: "tech" # tech: 技術記事 / idea: アイデア
topics: ["Go", "X", "Twitter"]
published: false
---
:::message
この記事は Go 初心者の筆者が公式のドキュメントを参照して試行錯誤をしながら Go で Web アプリを制作していく過程を記録していくものであり、俯瞰的にアプリの作成方法を伝えるものではありません。
:::

# Hello, world! - まずはサーバーを構築しよう！
## net/http パッケージ
HTTP サーバーを立てるには`net/http`パッケージを使用します。
[net/http の公式ドキュメント](https://pkg.go.dev/net/http)を見ながら進めていきましょう。
> このパッケージでは、HTTP クライアントやサーバーを実装することができます。[^nh]

ドキュメントの概要にあるサーバーの項目を見てみましょう。
> ListenAndServe には、アドレスとハンドラーを与えて HTTP サーバーを建てることができます。ハンドラーには通常`nil`を指定します。こうすることにより、DefaultServeMux を使用するようになります。Handle と HandleFunc はハンドラーを DefaultServeMux に追加していきます。

### ListenAndServe
では、`ListenAndServe`について見ていきましょう。
```go
func ListenAndServe(addr string, handler Handler) error
```
> ListenAndServe は TCP のアドレス`addr`をリッスンします。そして、`handler`を与えて`Serve`関数を呼び、受信したコネクションをハンドルします。

### Serve
`Serve`についても見てみましょう。
```go
func Serve(l net.Listener, handler Handler) error
```
> Serve はリスナー`l`で HTTP コネクションを受け入れて、それぞれに新しく`goroutine`を作成します。この`goroutine`は、リクエストを読み込んで、ハンドラーを呼び応答します。

## サーバーの構築
では早速`ListenAndServe`の説明にある例を実行して、"Hello, world!"を返すサーバーを構築してみましょう。
```go:main.go
package main

import (
	"io"
	"log"
	"net/http"
)

func main() {
	// Hello world, the web server

	helloHandler := func(w http.ResponseWriter, req *http.Request) {
		io.WriteString(w, "Hello, world!\n")
	}

	http.HandleFunc("/hello", helloHandler)
	log.Fatal(http.ListenAndServe(":8080", nil))
}
```
```sh
curl localhost:8080/hello
Hello, world!
```
できましたね！
例に出てきた`HandleFunc`などは後ほど詳しく見ていきましょう。
テストも書いておきます。
```go:main_test.go
package main

import (
	"io"
	"net/http"
	"testing"
)

func TestMain(t *testing.T) {
	go main()

	resp, err := http.Get("http://localhost:8080/hello")
	if err != nil {
		panic(err)
	}
	defer resp.Body.Close()

	body, err := io.ReadAll(resp.Body)
	if err != nil {
		panic(err)
	}

	var got, want string

	want = "Hello, world!\n"
	got = string(body)
	if got != want {
		t.Errorf("The body of http.Get(\"localhost:8080/hello\") is %v, but wants %v", got, want)
	}
}
```

# To-Do アプリを作ろう！
## ルーティングのパターンを確認
先程の`Hellow, world!`では`http.HandleFunc("/hello", helloHandler)`で`/hello`というパターンに`helloHandler`というハンドラーを設定しました。
パターンについては`ServeMux`の項に詳しくあります。
```go
type ServeMux struct {
	// contains filtered or unexported fields
}
```
> ServeMux は HTTP リクエストのマルチプレクサーです。受信したリクエストの URL と登録されたパターンの一覧を照合して、URL に最も適合したパターンに対応するハンドラーを呼び出します。
> パターン名は、固定されていたり、"/favicon.ico"のようにルートからのパスで書かれたり、"/images/"(末尾にスラッシュがあるのに注意)のようにルートからのサブツリーで表されたりします。長いパターンは短いものよりも優先されます。[...]
> 注意：スラッシュで終わるパターンはルートからのサブツリーを表わしますから、"/"というパターンは"/"というパスだけではなく、他の登録されているパターンに合致しなかった全てのパスに合致します。
> サブツリーが登録されていて末尾のスラッシュを取り除いた名前のリクエストを受信した場合には、ServeMux はその登録されているサブツリーにリダイレクトします。[...]
> パターンは任意でホスト名から始めることができ、URL の照合をそのホストに制限します。ホストを指定したパターンは一般的なパターンよりも優先されるので、"http://www.google.com/"へのリクエストを引き継ぐことなく、"/codesearch"と"codesearch.google.com/"の2つのパターンをハンドラーは登録できます。
> ServeMux は URLのリクエスト・パスやホストのヘッダーの正規化したり、ポートの削除したり、"."や".."、または重複したスラッシュを含むリクエストをクリーンな URL にリダイレクトしたりします。

## タスクのデータ構造を決定
タスクの構造体を定義します。
|field |type  |
|------|------|
|id    |int   |
|body  |string|
|isDone|bool  |

------
[^nh]: [net/http 公式ドキュメント](https://pkg.go.dev/net/http)からの引用です。翻訳は筆者に依るものです。以下、断わりの無い引用文はこのドキュメントを筆者が翻訳したものです。

