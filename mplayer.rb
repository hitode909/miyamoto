require 'rubygems'
require 'uri'
#require 'ruby-mplayer/lib/mplayer'

module Foo

  @library = open(File.expand_path('~/Music/iTunes/iTunes Music Library.xml')).read

  def self.get_next_track
    loop do
      file = URI.unescape(@library.scan(%r|>file:\/\/localhost(.*)<|).flatten.choice)
      return file if File.exist?(file)
    end
  end
end

class MPlayer
  def initialize
    @playing = false
    @io = IO.popen "mplayer -idle -slave 2>&1", 'r+'
    Thread.new{
      buffer = ''
      stop_thread = nil
      loop {
        chr = @io.read 1
        buffer << chr
        if chr =~ /[\r\n]/
          #puts buffer
          if buffer =~ /A:/
            if stop_thread
              puts "cansel timer"
              stop_thread.kill
              stop_thread = nil
            end
            cells = buffer.split(/ +/)
            next if cells.length < 8
            #p cells[1].to_f / cells[4].to_f
            if cells[1].to_f / cells[4].to_f > 0.995
              stop_thread = Thread.new {
                puts "set timer"
                sleep 1
                @playing = false
              }
            end
          end
          buffer = ''
        end
      }
    }
  end

  def playing?
    @playing
  end

  def open(path)
    self.command("loadfile #{path} 0")
  end

  def play(path)
    @playing = true
    self.command("loadfile #{path} 0")
  end

  def mute
    self.command("mute 1")
  end

  def unmute
    self.command("mute 0")
  end

  def pause
    @playing = !@playing
    self.command("pause")
  end

  def set_speed(speed)
    self.command("speed_set #{speed}")
  end

  def seek_with_diff(diff)
    self.command("seek #{diff} 0")
  end

  def seek_to_sec(sec)
    self.command("seek #{sec} 2")
  end

  def seek_to_percent(per)
    self.command("seek #{per} 1")
  end

  def command(text)
    puts "send: #{text}"
    @io.puts text
  end

  def method_missing( func, *args )
    @io.__send__(func, *args)
  end
end


mplayer = MPlayer.new


loop {
  track = Foo.get_next_track
  next unless File.file?(track)

  puts "playing #{track}"
  mplayer.play(track.gsub(' ', '\ '))
  #mplayer.seek_to_percent(98)

  speed = 1
  while mplayer.playing?
    mplayer.pause
    system 'say good morning!'
    mplayer.pause
    speed += 0.1
    mplayer.set_speed(speed)
    sleep 5
  end
}
