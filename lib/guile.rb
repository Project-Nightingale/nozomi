require './image_string_write.rb'
#bundle exec ruby guile.rb dsc_test_photo.jpg "神田明神"

base_image_file_name = ARGV[0]
write_string = ARGV[1]

ImageStringWrite.new(base_image_file_name, write_string, true).write()