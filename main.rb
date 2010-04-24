require 'rubygems'
require 'mplayer'

mplayer = MPlayer.new
timer = Time.now + (ARGV.first || 0.1).to_f * 60
is_past = false

loop do
  track = Foo.get_next_track
  next unless File.file?(track)

  puts "playing #{track}"
  mplayer.play(track.gsub(' ', '\ '))
  speed = 1.0

  while mplayer.playing?
    if Time.now > timer && !is_past
      mplayer.pause
      system "mplayer #{File.dirname(__FILE__)}/se.wav >& /dev/null"
      speed += 0.5
      mplayer.pause
      mplayer.set_speed(speed)
      is_past = true
    end
  end
end
