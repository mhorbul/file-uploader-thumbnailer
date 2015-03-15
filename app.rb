require 'sinatra'

set :root, File.dirname(__FILE__)
set :static, true

def create_thumbnail(filename)
  puts "Creating thumbnail ... #{filename}"
  filename, ext = filename.split('.')
  if ext.downcase == 'pdf'
    convert_to_png(filename, ext)
  else
    convert_to_pdf(filename, ext)
    convert_to_png(filename, 'pdf')
  end
end

def convert_to_pdf(filename, ext)
  output = [filename, 'pdf'].join('.')
  input =  [filename, ext].join('.')
  command = "unoconv -p 2220 -f pdf -o '#{File.join(settings.root, 'public', output)}' '#{File.join(settings.root, 'public', input)}'"
  puts command
  system(command)
end

def convert_to_png(filename, ext)
  input = File.join(settings.root, 'public', "#{filename}.#{ext}[0]")
  output = File.join(settings.root, 'public', "#{filename}.png")
  command = "convert -resize 100x200 '#{input}' '#{output}'"
  puts command
  system(command)
end

get "/" do
  erb :form
end

post '/upload' do

  @filename = params[:file][:filename]
  @file_name, @ext = @filename.split('.')
  @ext = @ext.downcase
  file = params[:file][:tempfile]

  File.open("./public/#{@filename}", 'wb') do |f|
    f.write(file.read)
  end

  create_thumbnail(@filename)

  erb :show
end
