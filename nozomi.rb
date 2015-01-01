require 'sinatra'
require 'haml'
require 'json'
require 'rabbit_swift'


# 静的コンテンツ参照のためのパス設定
set :public, File.dirname(__FILE__) + '/public'

# アップロード
get '/' do
  haml :index
end

get '/index.html' do
  haml :index
end

# アップロード処理
post '/upload' do
  if params[:file]

    save_path = "./public/images/#{params[:file][:filename]}"

    File.open(save_path, 'wb') do |f|
      p params[:file][:tempfile]
      f.write params[:file][:tempfile].read
      @mes = "アップロード成功"

      @file_url = send_object_strage(save_path)
    end
  else
    @mes = "アップロード失敗"
  end
  haml :upload
end


def send_object_strage(src_path)
  if @swift.nil?
    object_strage_conf_path = './config/object_strage.json'
    puts "LOAD " + object_strage_conf_path;
    File.open object_strage_conf_path do |file|
      conf = JSON.load(file.read)
      @swift = conf['swift']
    end
  end

  if @object_strage.nil?
    app_conf_path = './config/app.json'
    puts "LOAD " + app_conf_path;
    File.open app_conf_path do |file|
      conf = JSON.load(file.read)
      @object_strage = conf['object_strage']
    end
  end

  rabbit_swift_client = RabbitSwift::Client.new(@swift);
  token = rabbit_swift_client.get_token
  dest_path = @swift["endPoint"] + "/" + @object_strage["container"]

  # TODO ファイルのリネーム
  # TODO Masterサーバーに問い合わせ+クライアントIPなどの情報を送信
  # TODO Masterサーバー側で情報のDB登録
  # TODO 戻ってきた名前でファイルリネーム
  # TODO IP回数制限などのエラーが出た場合通知がくるのでハンドリングする


  status = rabbit_swift_client.upload(token, dest_path, src_path)
  if (status == RabbitSwift::Client::UPLOAD_SUCCESS_HTTP_STATUS_CODE)
     #TODO ファイル削除
  else

  end

  filename = File::basename(src_path);
  @object_strage['web_url'] + filename;
end