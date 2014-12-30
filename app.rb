require 'sinatra'
require 'haml'

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
      @mes = "アップロード成功"
    end
  else
    @mes = "アップロード失敗"
  end
  haml :upload
end
