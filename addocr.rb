#
# 自炊本のScrapboxにOCRデータを追加
#

require 'json'
require 'gyazo'

jsonfile = ARGV[0]
unless File.exist?(jsonfile)
  STDERR.puts "JSON file not found"
  STDERR.puts "Usage: addocr orig.json > new.json"
  exit
end

token = ENV['GYAZO_TOKEN'] # .bash_profileに書いてある
gyazo = Gyazo::Client.new access_token: token

origdata = JSON.parse(File.read(jsonfile))

jsondata = {}
pages = []
jsondata['pages'] = pages

origdata['pages'].each { |page|
  STDERR.puts page['title']
  newpage = {}
  newpage['title'] = page['title']
  lines = []
  newpage['lines'] = lines
  gyazoid = nil
  ocr_done = false
  page['lines'].each { |line|
    lines << line
    if line =~ /gyazo\.com\/([0-9a-f]{32})/i
      gyazoid = $1
    end
    if line =~ /OCR text/
      ocr_done = true
    end
  }
  if gyazoid && !ocr_done
    lines << ""
    lines << "(OCR text)"
    res = gyazo.image image_id: gyazoid
    if res && res[:ocr]
      res[:ocr][:description].split(/\n/).each { |line|
        lines << "> #{line}"
      }
    end
  end

  pages << newpage
}

puts jsondata.to_json
