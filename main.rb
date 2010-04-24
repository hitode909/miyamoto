require 'rubygems'
require 'uri'

library_path = File.expand_path('~/Music/iTunes/iTunes Music Library.xml')
home_path = File.expand_path('~')
library = open(library_path).read

puts library.scan(%r|>file:\/\/localhost(.*)<|).flatten.map{|s| URI.unescape(s)}