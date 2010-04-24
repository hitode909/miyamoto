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
    @thread_to_stop = nil
    @playing = false
    @resume_later = false
    @io = IO.popen "mplayer -idle -slave 2>&1", 'r+'
    Thread.new{
      buffer = ''
      stop_thread = nil
      loop {
        chr = @io.read 1
        buffer << chr
        if chr =~ /[\r\n]/ && !@pausing
          if buffer =~ /A:/
            cells = buffer.split(/ +/)
            next if cells.length < 8
            if cells[1].to_f / cells[4].to_f > 0.9
              self.set_thread_to_stop
            end
          end
          buffer = ''
        end
      }
    }
  end

  def set_thread_to_stop
    @thread_to_stop.kill if @thread_to_stop
    @thread_to_stop = Thread.new {
      sleep 1
      @playing = false
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
    @pausing = false
    @thread_to_stop = nil
    @resume_later = false
    self.command("loadfile #{path} 0")
  end

  def mute
    self.command("mute 1")
  end

  def unmute
    self.command("mute 0")
  end

  def pause
    if @resume_later
      self.set_thread_to_stop
      @resume_later = false
    else
      @resume_later = !!@thread_to_stop
    end
    @playing = !@playing
    @pausing = !@pausing
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
    #puts "send: #{text}"
    @io.puts text
  end

  def method_missing( func, *args )
    @io.__send__(func, *args)
  end
end
