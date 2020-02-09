#
# 自炊PDFから分解したjpgをS3とGyazoにアップロードしてScrapboxのJSONを作成
#
require 'digest/md5'
require 'json'

home = ENV['HOME']

jsondata = {}
pages = []
jsondata['pages'] = pages

jpegfiles = ARGV.grep /\.jpg/i

(0..jpegfiles.length).each { |i|
  file = jpegfiles[i]

  data = nil
  begin
    data = File.read(file)
  rescue
  end

  if data
    STDERR.puts file
  
    md5 = Digest::MD5.new.update(data).to_s
    md5 =~ /^(.)(.)/
    d1 = $1
    d2 = $2

    # S3にアップロード
    s3url = "http://masui.org.s3.amazonaws.com/#{d1}/#{d2}/#{md5}.jpg"
    STDERR.puts s3url
    STDERR.puts "ruby #{home}/bin/upload #{file}"
    system "ruby #{home}/bin/upload #{file}"

    # Gyazoにアップロード
    STDERR.puts "ruby #{home}/bin/gyazo_upload #{file}"
    gyazourl = `ruby #{home}/bin/gyazo_upload #{file}`.chomp
    STDERR.puts gyazourl
    
    sleep 1

    page = {}
    page['title'] = sprintf("%03d",i)
    lines = []
    page['lines'] = lines
    lines << page['title']
    if i == 0
      line1 = "[#{sprintf('%03d',i)}]  [#{sprintf('%03d',i+1)}]"
    elsif i == jpegfiles.length - 1
      line1 = "[#{sprintf('%03d',i-1)}]  [#{sprintf('%03d',i)}]"
    else
      line1 = "[#{sprintf('%03d',i-1)}]  [#{sprintf('%03d',i+1)}]"
    end

    lines << line1
    lines << "[[#{s3url} #{gyazourl}]]"
    lines << line1
    lines << ""

    pages << page

  end
}

puts jsondata.to_json
