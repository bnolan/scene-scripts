# Scene scripts

Some scripts for autoconverting sites into SceneVR scenes. Currently, only a reddit art gallery importer exists. It'd be cool to add importers for imgur galleries, pinterest boards, things like that.

## Installation

Clone the repo, `bundle install`, install imagemagick (we resize the images for performance), then edit `reddit-gallery.rb` to specify the subreddit you want to generate a gallery from. Then:

`ruby reddit-gallery.rb`

You'll get some progress messages, the scene and it's images will be generated in the scenes subdirectory.