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

# アップロード処理
post '/upload' do
  if params[:file]

    save_path = "./public/images/#{params[:file][:filename]}"

    File.open(save_path, 'wb') do |f|
      p params[:file][:tempfile]
      f.write params[:file][:tempfile].read
      @mes = "アップロード成功 " + save_path

      @file_url = send_object_strage(save_path)
    end
  else
    @mes = "アップロード失敗"
  end
  haml :upload
end


def send_object_strage(src_path)
  object_strage_conf_path = './config/object_strage.json'
  File.open object_strage_conf_path do |file|
    conf = JSON.load(file.read)
    @swift = conf['swift']
  end

  app_conf_path = './config/app.json'
  File.open app_conf_path do |file|
    conf = JSON.load(file.read)
    @object_strage = conf['object_strage']
  end

  rabbit_swift_client = RabbitSwift::Client.new(@swift);
  token = rabbit_swift_client.get_token
  dest_path = @swift["endPoint"] + "/" + @object_strage["container"]

  status = rabbit_swift_client.upload(token, dest_path, src_path)
  if (status == RabbitSwift::Client::UPLOAD_SUCCESS_HTTP_STATUS_CODE)
     //TODO ファイル削除
  else

  end

  filename = "";
  @object_strage + "/" + filename;
end