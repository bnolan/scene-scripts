# Convert a twitter feed to a scene. Dumb that twitter doesn't have an unauthenticated json
# feed, but whatever.
#
# Get your application credentials here:
#   https://apps.twitter.com/app/new

require 'twitter'
require 'uri'

# For the vector class
require 'gmath3D'

USER = "scenevr".downcase
DOWNLOAD = true

client = Twitter::REST::Client.new do |config|
  config.consumer_key    = ENV["TWITTER_KEY"]
  config.consumer_secret = ENV["TWITTER_SECRET"]
end

puts "Fetching timeline for @#{USER}..."

# This one weird hack is so I can cache the json locally and not hit API rate limits
timeline = JSON.parse(client.user_timeline("scenevr").collect(&:to_h).to_json)
# timeline = JSON.parse(open("./tmp/tweets.json").readlines.join)

puts "Fetching tweets and media..."
`rm scenes/images/twitter-#{USER}-* 2>/dev/null` if DOWNLOAD

xml = "<scene>\n"
xml += <<-EOF
  <spawn position="0 0 0" />
  <skybox style="color: linear-gradient(#ffffff, #00aaff)" />
EOF

i = 0
timeline.each do |tweet|
  text = tweet["text"]
  img = nil
  margin = 0

  if tweet["entities"] && tweet["entities"]["media"]
    img = tweet["entities"]["media"].first["media_url"]

    uri = URI.parse(img)
    extension = File.extname(uri.path).downcase

    puts " * #{uri.to_s}"

    if DOWNLOAD
      `curl #{uri.to_s} -s -o scenes/images/twitter-#{USER}-#{i}#{extension}` || next
      `mogrify -resize 500x450 scenes/images/twitter-#{USER}-#{i}#{extension}` || next
    end

    height = `identify scenes/images/twitter-#{USER}-#{i}#{extension}`.match(/x(\d+)/)[1].to_i
    margin = (512 - 40 - height) / 2
  end

  x = i % 5
  z = (i / 5).floor

  v = GMath3D::Vector3.new(x, 0, -z) * 5
  v += GMath3D::Vector3.new(5, 1.5, -5)

  xml += <<-EOF
    <billboard position="#{v.x} #{v.y} #{v.z}" rotation="0 0.785 0" scale="3 3 0.3">
      <![CDATA[
        <center style="margin-top: #{margin}px; font-size: 2em">
          <img src="/images/twitter-#{USER}-#{i}#{extension}" style="max-width: 100%" /><br />
          #{text}
        </center>
      ]]>
    </billboard>
EOF

  i += 1
end

xml += "</scene>"

File.open("./scenes/twitter-#{USER}.xml", "w") { |f| f.write xml }

puts "Visit scenes/twitter-#{USER}.xml to see the gallery."
