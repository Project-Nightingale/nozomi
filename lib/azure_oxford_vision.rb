require 'json'
require './lib/image_string_write_oxford'
require 'logger'

class AzureOxfordVision


  def initialize(target_file_or_url, conf)
    @log = Logger.new("./log/nogomi_oxford.log")

    uri = URI('https://api.projectoxford.ai/vision/v1/analyses')
    uri.query = URI.encode_www_form({'visualFeatures' => 'All'})
    request = Net::HTTP::Post.new(uri.request_uri)
    request['Content-Type'] = 'application/octet-stream'
    request['Ocp-Apim-Subscription-Key'] = conf['subscription_key']

    File.open(target_file_or_url) do |filename_stream_data|
      request.body = filename_stream_data.read
      response = Net::HTTP.start(uri.host, uri.port, :use_ssl => uri.scheme == 'https') do |http|
        http.request(request)
      end
      puts response.body
      @response_body = response.body

    end

    @conf = conf
    @write_filename = target_file_or_url
  end

  def iamge_info_write(face_data)
    p @write_filename
    #imageを初期化
    #loopして情報を書き込む
    #出力ファイルを返す
    face_data.each do |data|
      left = data['faceRectangle']['left']
      top = data['faceRectangle']['top']
      height = data['faceRectangle']['height']
      write_string = sprintf('%d歳\n%s', data['age'], data['gender'] == 'Male' ?  '男性' : '女性')
      position_x = left
      position_y = top + height + 1
      puts "#{position_x} #{position_y}"

      #TODO 人物が複数いたらここがループする。ファイルリードが効率が悪いので改良が必要
      gps = ImageStringWriteOxford.new(@write_filename, write_string, "", false, 16, position_x, position_y).write

      @log.info([@write_filename, data['age'].to_s, data['gender'].to_s, gps[0], gps[1]].join("\t"))
    end

    #ここで再度コピーライトを書く
    ImageStringWriteOxford.new(@write_filename, @conf['oxford_app']['copyright'], "", false, 16, 0, 0).write
    @write_filename
  end


  def image_info_parse()
    image_info = JSON.load(@response_body)
    face_data = image_info['faces']
    return if face_data.nil?
    iamge_info_write(face_data)
  end

end