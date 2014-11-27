# Generate a gallery from an image gallery subreddit. Requires imagemagick to be installed in your
# path. Assumes the billboards are rendered at 512x512.

require 'open-uri'
require 'json'
require 'uri'

# For the vector class
require 'gmath3D'

DOWNLOAD = true

puts "Fetching json..."

json = JSON.parse(open("http://www.colourlovers.com/api/palettes/top?format=json").readlines.join)

xml = "<scene>\n"
xml += <<-EOF
  <spawn position="0 0 0" />

EOF

i = 0
json.each do |palette|
  title = palette["title"].slice(0,70)

  x = i % 5
  z = (i / 5).floor

  v = GMath3D::Vector3.new(x, 0, -z) * 5
  v += GMath3D::Vector3.new(5, 0.5, -5)

  xml += <<-EOF
    <billboard position="#{v.x} #{v.y} #{v.z}" rotation="0 0 0" scale="1 1 0.1">
      <![CDATA[
        <center style="font-size: 4em; margin-top: 40px">#{title}</center>
      ]]>
    </billboard>
EOF

  v.y = 0.2
  v += GMath3D::Vector3.new(1.5, 0, 0)

  palette['colors'].each do |color|
    xml += "<box color='##{color}' scale='0.4 0.4 0.4' position='#{v.x} #{v.y} #{v.z}' />"
    v += GMath3D::Vector3.new(0, 0.4, 0)
  end

  i += 1
end

xml += "</scene>"

File.open("./scenes/colorlovers.xml", "w") { |f| f.write xml }

puts "Visit /colorlovers.xml to see the gallery."
