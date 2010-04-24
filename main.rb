require 'rubygems'
require 'uri'
require 'ruby-mplayer/lib/mplayer'

module Foo 

  @library = open(File.expand_path('~/Music/iTunes/iTunes Music Library.xml')).read

  def self.get_next_track
    loop do
      file = URI.unescape(@library.scan(%r|>file:\/\/localhost(.*)<|).flatten.choice)
      return file if File.exist?(file)
    end
  end

end

mplayer = Mplayer.new
p mplayer
mplayer.play(Foo.get_next_track)

