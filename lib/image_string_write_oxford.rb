require './lib/image_string_write'

class ImageStringWriteOxford < ImageStringWrite

  # 横幅に応じて自動的にフォントサイズをきめる
  def auto_font_size(width)
    case width
      when (0..500) then 12
      when (501..1000) then 16
      when (1001..1500) then 20
      when (1501..2000) then 30
      when (2001..2500) then 45
      when (2501..3000) then 60
      when (3001..3500) then 80
      when (3501..4000) then 100
      when (4001..4500) then 120
      when (4501..5000) then 160
      when (5001..Float::INFINITY) then 200
    end
  end

  def write
    img  = Magick::ImageList.new(@img_file)

    if img.format != 'JPEG' && img.format != 'PNG' && img.format != 'GIF'
      raise Exception
    end

    # 文字を書き込む前に縦横情報を元に画像を回転する
    # 何も処理しない場合でも画像を回転しておく
    img.auto_orient!

    if !@write_string.empty?

      draw = Magick::Draw.new
      font_size = auto_font_size(img.columns)

      # 文字の影 ( 1pt 右下へずらす )
      draw.annotate(img, 0, 0, @position_x - 1, @position_y -1 , @write_string) do
        self.font      = FONT                      # フォント
        self.fill      = 'black'                   # フォント塗りつぶし色(黒)
        self.stroke    = 'transparent'             # フォント縁取り色(透過)
        self.pointsize =  font_size                      # フォントサイズ
        self.gravity   = Magick::NorthWestGravity  # 描画基準位置
      end

      # 文字
      draw.annotate(img, 0, 0, @position_x, @position_y, @write_string) do
        self.font      = FONT                      # フォント
        self.fill      = 'red'                   # フォント塗りつぶし色(白)
        self.stroke    = 'transparent'             # フォント縁取り色(透過)
        self.pointsize = font_size                         # フォントサイズ
        self.gravity   = Magick::NorthWestGravity  # 描画基準位置
      end
    end

    if !@input_desc.empty?

      draw = Magick::Draw.new

      px = 0
      py = 0

      # 文字の影
      draw.annotate(img, 0, 0, px, py, @input_desc) do
        self.font      = FONT                      # フォント
        self.fill      = 'black'                   # フォント塗りつぶし色(黒)
        self.stroke    = 'transparent'             # フォント縁取り色(透過)
        self.pointsize =  18                      # フォントサイズ
        self.gravity   = Magick::CenterGravity  # 描画基準位置
      end

      # 文字
      draw.annotate(img, 0, 0, px + 1, py + 1 , @input_desc) do
        self.font      = FONT                      # フォント
        self.fill      = 'red'                   # フォント塗りつぶし色(白)
        self.stroke    = 'transparent'             # フォント縁取り色(透過)
        self.pointsize = 18                         # フォントサイズ
        self.gravity   = Magick::CenterGravity  # 描画基準位置
      end
    end

    @latitude = nil
    @longitude = nil
    # 位置情報を保存
    # ref:http://www.iwazer.com/~iwazawa/diary/2013/03/convert-photo-location-to-digits-with-rmagick.html
    if img.format == 'JPEG' && !img.get_exif_by_entry('GPSLatitude').nil? && !img.get_exif_by_entry('GPSLongitude').nil? &&
        !img.get_exif_by_entry('GPSLatitude')[0][1].nil? && !img.get_exif_by_entry('GPSLongitude')[0][1].nil? then

      exif_lat = img.get_exif_by_entry('GPSLatitude')[0][1].split(',').map(&:strip)
      p img.get_exif_by_entry('GPSLatitude')
      # => ["35/1", "3850/100", "0/1"]
      exif_lng = img.get_exif_by_entry('GPSLongitude')[0][1].split(',').map(&:strip)
      p img.get_exif_by_entry('GPSLongitude')
      # => ["139/1", "4497/100", "0/1"]
      @latitude = (Rational(exif_lat[0]) + Rational(exif_lat[1])/60 + Rational(exif_lat[2])/3600).to_f
      # => 35.641666666666666
      @longitude = (Rational(exif_lng[0]) + Rational(exif_lng[1])/60 + Rational(exif_lng[2])/3600).to_f

      puts @latitude.to_s + "\t" + @longitude.to_s
    end

    # Exif情報を削除
    if img.format == 'JPEG' && @del_exif
      img.strip!
    end

    # 画像生成
    img.write(@img_file)
    [@latitude.to_s, @longitude.to_s]
  end
end

