<h1>自炊本をScrapboxで読む工夫</h1>

<h2>手順</h2>

<ul>
  <li>書籍を裁断</li>
  <li>ScanSnapでスキャンしてPDFを作成</li>
  <li>PDFをJPEGに分解してフォルダに置く<br>
    <code>% pdfimages -j mybook.pdf 'title'</code>
  </li>
  <li>pbmになってる場合はjpgに変換<br>
    <code>% ruby pbm2jpg.rb *.pbm</code><br>
  </li>
  <li>全JPEGをS3とGyazoにアップロードしつつScrapbox用のJSONを生成<br>
    <code>% ruby makejson.rb *.jpg > book.json</code>
  </li>
  <li>Scrapboxプロジェクトを作ってJSONをインポート</li>
  <li>OCRデータを取得してインポート<br>
    <code>% ruby addocr.rb book.json > book-ocr.json</code>
  </li>  
</ul>
