require 'sinatra'
require 'haml'
require 'json'
require 'rabbit_swift'
require 'fileutils'
require './lib/image_string_write.rb'

# 静的コンテンツ参照のためのパス設定
set :public, File.dirname(__FILE__) + '/public'

# アップロード
get '/' do
  haml :index
end

get '/index.html' do
  haml :index
end

get '/mypage' do
  old_cookie = request.cookies['upload_files'] ? request.cookies['upload_files'] : ''
  @filename_and_deletekey = old_cookie.split('|')
  haml :mypage
end

# アップロード処理
post '/upload' do
  if params[:file]

    save_path = "./public/images/#{params[:file][:filename]}"

    File.open(save_path, 'wb') do |f|
      p params[:file][:tempfile]
      f.write params[:file][:tempfile].read
      @mes = "アップロード成功"

      p params[:input_desc]
      input_desc = sanitizing(params[:input_desc])

      # ファイルサイズ制限（nginxでやる
      # ファイル・タイプチェック&イメージフィルタ
      begin
        image_filter(save_path, params[:write_string], input_desc, params[:del_exif].to_s == 'true' ? true : false)
        @file_url = send_object_strage(save_path)

        old_cookie = request.cookies['upload_files'] ? request.cookies['upload_files'] : ''
        response.set_cookie "upload_files", old_cookie + '|' + @new_file_name + ':' + gen_delete_key(16)

      rescue => ex
        p ex
        p ex.backtrace
        @mes = "アップロード後にエラーが発生しました。ファイル形式が誤っている可能性があります。"
        File.unlink(save_path)
      end
    end


  else
    @mes = "アップロード失敗"
  end
  haml :upload
end

def image_filter(src_path, write_string, input_desc, del_exif)
  ImageStringWrite.new(src_path, write_string, input_desc, del_exif).write()
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


  # TODO ファイルのリネーム処理ブロック開始
  # TODO Masterサーバーにファイル名問い合わせ+クライアントIPなどの情報を送信 (REST API [POST JSON])
  # TODO Masterサーバー側で情報のDB登録
  # TODO 戻ってきた名前でファイルリネーム
  new_file_name = get_rand_filename + File.extname(src_path)
  new_file_path = File.join(File::dirname(src_path), new_file_name)
  File.rename(src_path, new_file_path)

  # TODO IP回数制限などのエラーが出た場合通知がくるのでハンドリングする

  rabbit_swift_client = RabbitSwift::Client.new(@swift);

  #TODO tokenはキャッシュ化(1Hぐらいでmemchacedに入れておく)
  token = rabbit_swift_client.get_token
  dest_path = File.join(@swift["endPoint"], @object_strage["container"])
  status = rabbit_swift_client.upload(token, dest_path, new_file_path)
  if (status == RabbitSwift::Client::UPLOAD_SUCCESS_HTTP_STATUS_CODE)
    #ファイル削除
    File.unlink(new_file_path)
  else

  end

  @new_file_name = new_file_name
  File.join(@object_strage['web_url'], new_file_name)
end

#TODO
#暫定でローカルでランダムファイル名を取得
def get_rand_filename
  big = ('A'..'Z').to_a;
  small = ('a'..'z').to_a
  num = (0..9).to_a
  character_pattern = big + small + num;
  # 7文字
  # 3,521,614,606,208 パターン (3兆)
  (0...7).map{ character_pattern[rand(62)] }.join
end

#ファイル削除キーを発行する
def gen_delete_key(size)
  big = ('A'..'Z').to_a
  small = ('a'..'z').to_a
  num = (0..9).to_a
  character_pattern = big + small + num;
  # 32文字
  # TODO 暗号化
  (0...size).map{ character_pattern[rand(62)] }.join
end

#暫定でRMagickでエラーが出そうな文字を全角に変換する
def sanitizing(input_desc)
  trans = input_desc
  trans = trans.gsub('@', '＠')
  trans.gsub('$', '＄')
end