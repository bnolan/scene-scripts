# Scene scripts

Some scripts for autoconverting sites into SceneVR scenes. Currently, only a reddit art gallery importer exists. It'd be cool to add importers for imgur galleries, pinterest boards, things like that.

## Installation

Clone the repo, `bundle install`, install imagemagick (we resize the images for performance).

### Windows installation

Install ruby 1.9.3 from [rubyinstaller.org](http://rubyinstaller.org/). Make sure to add it to your path. Install [ImageMagick-6.9.0-0-Q16-x64-dll.exe](http://www.imagemagick.org/script/binary-releases.php) and add it to your path. Install [curl](http://curl.haxx.se/latest.cgi?curl=win64-ssl-sspi) and add it to your path (or just install it to c:\windows).

# Run script

Edit `reddit-gallery.rb` to specify the subreddit you want to generate a gallery from.

`ruby reddit-gallery.rb`

You'll get some progress messages, the scene and it's images will be generated in the scenes subdirectory.

## Screenshot

![Street art gallery](http://i.imgur.com/YUWHFqR.png)