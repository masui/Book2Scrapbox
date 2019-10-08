require 'digest/md5'
require 'json'
require 'gyazo'

S3ROOT = ENV['S3ROOT']
unless S3ROOT
  STDERR.puts "S3ROOT not defined"
  exit
end
STDERR.puts "using #{S3ROOT}..."

token = ENV['GYAZO_TOKEN'] # .bash_profileに書いてある
gyazo = Gyazo::Client.new access_token: token

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
    s3path = "#{S3ROOT}/masui.org/#{d1}/#{d2}/#{md5}.jpg"
    s3url = "http://masui.org.s3.amazonaws.com/#{d1}/#{d2}/#{md5}.jpg"
    STDERR.puts s3url
    STDERR.puts s3path

    unless File.exist?(s3path)
      File.write(s3path,data)
    end
    
    res = gyazo.upload imagefile: s3path
    gyazourl = res[:permalink_url]
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

    lines << "[[#{s3url} #{gyazourl}]]"
    lines << line1
    lines << ""

    pages << page

  end
}

puts jsondata.to_json

