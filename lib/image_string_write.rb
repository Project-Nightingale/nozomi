require 'RMagick'

class ImageStringWrite

  FONT = RUBY_PLATFORM.downcase == 'x86_64-linux' ? "./freefont/NotoSansCJKjp-Medium.otf" : "/Library/Fonts/Osaka.ttf"

  def initialize(filename, write_string = nil, input_desc = nil, del_exif = false, font_size = 16, position_x = 5, position_y = 5)
    @position_x = position_x
    @position_y = position_y
    @img_file = filename
    @write_string = write_string
    @font_size = font_size
    @del_exif = del_exif
    @input_desc = input_desc
  end

  # 横幅に応じて自動的にフォントサイズをきめる
  def auto_font_size(width)
    case width
      when (0..500) then 25
      when (501..1000) then 50
      when (1001..1500) then 100
      when (1501..2000) then 150
      when (2001..2500) then 200
      when (2501..3000) then 250
      when (3001..3500) then 300
      when (3501..4000) then 350
      when (4001..4500) then 400
      when (4501..5000) then 450
      when (5001..Float::INFINITY) then 500
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
      font_size = auto_font_size(img.columns)

      p @input_desc

      # 文字の影
      draw.annotate(img, 0, 0, @position_x - 1, @position_y -1 , @input_desc) do
        self.font      = FONT                      # フォント
        self.fill      = 'black'                   # フォント塗りつぶし色(黒)
        self.stroke    = 'transparent'             # フォント縁取り色(透過)
        self.pointsize =  font_size                      # フォントサイズ
        self.gravity   = Magick::CenterGravity  # 描画基準位置
      end

      # 文字
      draw.annotate(img, 0, 0, @position_x, @position_y, @input_desc) do
        self.font      = FONT                      # フォント
        self.fill      = 'red'                   # フォント塗りつぶし色(白)
        self.stroke    = 'transparent'             # フォント縁取り色(透過)
        self.pointsize = font_size                         # フォントサイズ
        self.gravity   = Magick::CenterGravity  # 描画基準位置
      end
    end

    # Exif情報を削除
    if img.format == 'JPEG' && @del_exif
      img.strip!
    end

    # 画像生成
    img.write(@img_file)
  end



end

