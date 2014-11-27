# Convert a pinterest board to a scene. Pretty gross because there's no json api.

require 'open-uri'
require 'uri'
require 'nokogiri'

# For the vector class
require 'gmath3D'

BOARD = "ristari/recycle-upcycle-etc".downcase
BOARD_NAME = BOARD.gsub(/\//,'-')
DOWNLOAD = true

puts "Fetching /#{BOARD} as html..."
html = Nokogiri::HTML(open("http://www.pinterest.com/#{BOARD}.json").readlines.join)

puts "Downloading and resizing images..."
`rm scenes/images/pinterest-#{BOARD_NAME}-* 2>/dev/null` if DOWNLOAD

xml = "<scene>\n"
xml += <<-EOF
  <spawn position="0 0 0" />
EOF

i = 0
html.css('.PinBase').each do |pin|
  begin
    title = (pin.css('.pinDescription')[0] || pin.css(".richPinGridTitle")[0]).text.strip.slice(0,70)
  rescue e
    next
  end

  img = pin.css('.pinImg')[0]["src"]

  uri = URI.parse(img)
  extension = File.extname(uri.path).downcase

  next unless extension == ".jpg" || extension == ".jpeg" || extension == ".png"

  puts " * #{uri.to_s}"

  if DOWNLOAD
    `curl #{uri.to_s} -s -o scenes/images/pinterest-#{BOARD_NAME}-#{i}#{extension}` || next
    `mogrify -resize 500x450 scenes/images/pinterest-#{BOARD_NAME}-#{i}#{extension}` || next
  end
  
  x = i % 5
  z = (i / 5).floor

  v = GMath3D::Vector3.new(x, 0, -z) * 5
  v += GMath3D::Vector3.new(5, 1.5, -5)

  height = `identify scenes/images/pinterest-#{BOARD_NAME}-#{i}#{extension}`.match(/x(\d+)/)[1].to_i
  margin = (512 - 40 - height) / 2

  xml += <<-EOF
    <billboard position="#{v.x} #{v.y} #{v.z}" rotation="0 0.785 0" scale="3 3 0.3">
      <![CDATA[
        <center style="margin-top: #{margin}px; font-size: 2em">
          <img src="/images/pinterest-#{BOARD_NAME}-#{i}#{extension}" style="max-width: 100%" /><br />
          #{title}
        </center>
      ]]>
    </billboard>
EOF

  i += 1
end

xml += "</scene>"

File.open("./scenes/pinterest-#{BOARD_NAME}.xml", "w") { |f| f.write xml }

puts "Visit /pinterest-#{BOARD_NAME}.xml to see the gallery."
