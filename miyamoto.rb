#!/usr/bin/env ruby
# -*- coding: utf-8 -*-

self_file =
  if File.symlink?(__FILE__)
    require 'pathname'
    Pathname.new(__FILE__).realpath
  else
    __FILE__
  end
$:.unshift(File.dirname(self_file) + "/lib")

require 'mplayer'
require 'track_finder'

unless ARGV.first
  puts "USAGE: ./miyamoto.rb $minute"
  exit 1
end

mplayer = MPlayer.new
secs = (ARGV.first || 0.1).to_f * 60
timer = Time.now + secs
is_past = false
track = nil

Thread.new {
  loop {
    STDOUT.write "playing \"#{File.basename("#{track}")}\" #{(timer - Time.now).to_i}      \r"
    STDOUT.flush
    sleep 1
  }
}

speed = 1.0

speed_up_thread = Thread.new {
  loop {
    if Time.now > timer && !mplayer.pausing
      speed += 0.1
      mplayer.set_speed(speed)
    end
    sleep Time.now > timer ? 30 : 3.1
  }
}

loop do
  track = TrackFinder.get_next_track
  next unless File.file?(track)

  mplayer.play(track.gsub(' ', '\ '))

  while mplayer.playing?
    if Time.now > timer && !is_past
      mplayer.pause
      system "mplayer #{File.dirname(__FILE__)}/lib/se.wav >& /dev/null"
      speed += 0.5
      mplayer.pause
      mplayer.set_speed(speed)
      is_past = true
    end
    sleep 1
  end
end
