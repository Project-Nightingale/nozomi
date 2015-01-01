## 設定
cp config/sample.app.conf.json config/app.conf.json

## 起動に必要なもの

(オブジェクトストレージを使用する場合)

memcached サーバー = オブジェクトストレージの鍵を格納するのに使用

## 起動

### 開発

```
bundle exec unicorn -c unicorn.rb
```

### 本番

```
bundle exec unicorn -c unicorn.rb  -D -E production -p 80
```
-D デーモン化
-E production