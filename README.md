## 設定
cp config/sample.app.conf.json config/app.conf.json

## 起動に必要なもの

(オブジェクトストレージを使用する場合)
memcached サーバー = オブジェクトストレージの鍵を格納するのに使用

## 起動

bundle exec ruby nozomi.rb　-p 80 -e production

