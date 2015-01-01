## 設定
cp config/sample.app.conf.json config/app.conf.json

## 起動に必要なもの

(オブジェクトストレージを使用する場合)

memcached サーバー = オブジェクトストレージの鍵を格納するのに使用

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