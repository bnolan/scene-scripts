# Convert a pinterest board to a scene. Pretty gross because there's no json api.

require 'open-uri'
require 'uri'
require 'nokogiri'

# For the vector class
require 'gmath3D'

URL = "http://leon.vrsites.com/1/853"
SLUG = URI.parse(URL).path.downcase.gsub(/[^a-z0-9]+/,'-').sub(/^-+/,'')
DOWNLOAD = true

puts "Fetching #{URL} as html..."
html = Nokogiri::HTML(open(URL).readlines.join)

puts "Downloading models..."
`rm scenes/images/janus-#{SLUG}-* 2>/dev/null` if DOWNLOAD

xml = "<scene>\n"
xml += <<-EOF
  <spawn position="0 0 0" />
EOF

SCALE_DEFAULT = GMath3D::Vector3.new(1,1,1)
ROTATION_DEFAULT = GMath3D::Vector3.new(0,0,1)
POSITION_DEFAULT = GMath3D::Vector3.new(0,0,0)

def fwd_to_euler(vector)
  GMath3D::Vector3.new(0,0,0)
end

def parse_vector(obj, attribute, default)
  if value = obj[attribute]
    value = value.split ' '
    GMath3D::Vector3.new value[0].to_f, value[1].to_f, value[2].to_f
  else
    default
  end
end

assets = {}

i = 0
html.css('fireboxroom assets assetobject').each do |obj|
  id = obj['id']

  uri = URI.join(URL, obj['src'])
  extension = File.extname(uri.path).downcase
  name = File.basename(uri.path, extension).downcase
  path = "janus-#{SLUG}-#{name}#{extension}"

  texture = obj['tex'] || obj['tex0']
  if texture
    texture_uri = URI.join(URL, texture)
    texture_extension = File.extname(texture_uri.path).downcase
    texture_name = File.basename(texture_uri.path, texture_extension).downcase
    texture_path = "janus-#{SLUG}-#{texture_name}#{texture_extension}"
  end

  assets[id] = {
    :uri => uri.to_s,
    :texture => texture_path,
    :mtl => obj['mtl'],
    :path => path
  }

  if DOWNLOAD
    print " * Fetching #{uri}... "
    if `curl #{uri.to_s} -s -o scenes/models/#{path}`
      puts "ok"
    else
      puts "failed"
    end

    if texture
      print " * Fetching #{texture_uri}... "
      if `curl #{texture_uri.to_s} -s -o scenes/images/#{texture_path}`
        puts "ok"
      else
        puts "failed"
      end
    end
  end

  i += 1
end

html.css('fireboxroom object').each do |obj|
  asset = assets[obj['id']]

  src = "/models/" + asset[:path]
  position = parse_vector(obj, 'pos', POSITION_DEFAULT)
  scale = parse_vector(obj, 'scale', SCALE_DEFAULT)
  rotation = fwd_to_euler(parse_vector(obj, 'fwd', ROTATION_DEFAULT))

  texture = asset[:texture]

  xml += <<-EOF
    <model 
      src='#{src}' 
      style='collision: none; color: #ccc; #{texture ? "light-map: url(/images/#{texture});" : ''}' 
      position='#{position.x} #{position.y} #{position.z}' 
      scale='#{scale.x} #{scale.y} #{scale.z}' 
      rotation='#{rotation.x} #{rotation.y} #{rotation.z}'
    />
EOF
end

html.css('fireboxroom paragraph, fireboxroom text').each do |obj|
  text = obj.text
  position = parse_vector(obj, 'pos', POSITION_DEFAULT)
  scale = parse_vector(obj, 'scale', SCALE_DEFAULT)
  rotation = fwd_to_euler(parse_vector(obj, 'fwd', ROTATION_DEFAULT))

  scale.z = 0.1

  xml += <<-EOF
    <billboard position='#{position.x} #{position.y} #{position.z}' scale='#{scale.x} #{scale.y} #{scale.z}' rotation='#{rotation.x} #{rotation.y} #{rotation.z}'>
      <![CDATA[
        <center>
          #{text}
        </center>
      ]]>
    </billboard>
EOF
end

xml += "</scene>"

# puts xml

File.open("./scenes/janusvr-#{SLUG}.xml", "w") { |f| f.write xml }

puts "Visit /janusvr-#{SLUG}.xml to see the gallery."
