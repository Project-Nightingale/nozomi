#Nozomi - 希

## 概要

画像アップローダーです。

アップロードされた画像はサーバー側で保存せずクラウド・ストレージに送信します。

画像のレスポンスはクラウド・ストレージ(Amazon S3など)に任せるためAPサーバーの負荷を軽減できます。

画像のURLを短くするためクラウド・ストレージのURLをNginxでリバースプロキシを使い短くしています。

クライアントから見た仕様はimgur.comをインスパイアしています。

## 設定
サンプルファイルをコピーし適切な設定値に変更します

* cp config/sample.app.json config/app.json
* cp config/sample.object_strage.json config/object_strage.json

## 起動に必要なもの

オブジェクトストレージサーバー接続情報 (Amazon S3, OpenStack Swift, Google CloudStrage, Azure Strage)

memcached サーバー = オブジェクトストレージの鍵を格納するのに使用

現状 OpenStack Swiftに対応しています。

## システム構成

Sinatra + Unicorn + Nignx での運用を想定しています。

## 起動

予めnginxの設定をし、nginxを起動して
UnicornをUNIXドメインソケット経由で起動します

### 開発

```
bundle exec unicorn -c unicorn.rb
```

### 本番

```
bundle exec unicorn -c unicorn.rb -D -E production
```
-D デーモン化
-E production

デーモン化した後の再起動

```
kill -HUP `cat /tmp/unicorn.pid`
```

### ライセンス

MIT License