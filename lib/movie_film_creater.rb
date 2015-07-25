require 'RMagick'

class MovieFilmCreater

  def initialize(image_file1, image_file2, image_file3, image_file4)
    @image_file1 = image_file1
    @image_file2 = image_file2
    @image_file3 = image_file3
    @image_file4 = image_file4
  end

  def read_image(filename)
    puts "-----"
    p filename
    #背景黒の画像に重ねるため透明度を上げてフィルムっぽくする
    target_image =  Magick::Image.read(filename).first { self.background_color = "none" }

    #フィルムコマに合わせるためリサイズ
    target_image.resize!(@pattern[:resize_width], @pattern[:resize_height])
    #TODO 縦が100以上なら上から縦100までに切る->自動的に圧縮されてカッティングされるので先に比率を計算する

    target_image.alpha(Magick::ActivateAlphaChannel)
    target_image.opacity = Magick::QuantumRange - (Magick::QuantumRange * 0.8)
    target_image
  end

  def write
    create_image_filename = './public/images/film_' + Time.now.to_i.to_s + '.png'
    image = Magick::Image.read("./lib/base_image/base2.png").first

    base2 = {
        resize_width: 165,
        resize_height: 93,
        image1_position: [62, 38],
        image2_position: [62, 180],
        image3_position: [62, 322],
        image4_position: [62, 465]
    }

    @pattern = base2

#TODO ネットURLから画像を取得する
#TODO ADV 指定した動画から画像を切り出してくっつける
#TODO ADV アニメGIFを分解して画像をくっつける

    image_list = [read_image(@image_file1),read_image(@image_file2),read_image(@image_file3),read_image(@image_file4)]

    image.composite!(image_list[0], @pattern[:image1_position][0],@pattern[:image1_position][1], Magick::OverCompositeOp)
    image.composite!(image_list[1], @pattern[:image2_position][0],@pattern[:image2_position][1], Magick::OverCompositeOp)
    image.composite!(image_list[2], @pattern[:image3_position][0],@pattern[:image3_position][1], Magick::OverCompositeOp)
    image.composite!(image_list[3], @pattern[:image4_position][0],@pattern[:image4_position][1], Magick::OverCompositeOp)

    image.write(create_image_filename)

    image_list[0].destroy!
    image_list[1].destroy!
    image_list[2].destroy!
    image_list[3].destroy!
    image.destroy!

    create_image_filename
  end

end

