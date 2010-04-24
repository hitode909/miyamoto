require 'uri'

module TrackFinder
  @library = open(File.expand_path('~/Music/iTunes/iTunes Music Library.xml')).read

  def self.get_next_track
    loop do
      file = URI.unescape(@library.scan(%r|>file:\/\/localhost(.*)<|).flatten.choice)
      return file if File.exist?(file)
    end
  end
end
