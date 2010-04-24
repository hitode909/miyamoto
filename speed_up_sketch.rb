require 'mplayer'

mplayer = MPlayer.new


loop {
  track = Foo.get_next_track
  next unless File.file?(track)

  puts "playing #{track}"
  mplayer.play(track.gsub(' ', '\ '))
  mplayer.seek_to_percent(80)

  speed = 2
  while mplayer.playing?
    mplayer.pause
    system 'mplayer se.wav'
    mplayer.pause
    speed += 0.1
    mplayer.set_speed(speed)
    sleep 5
  end
}
