#! /usr/bin/env ruby

require 'rubygems'
require 'id3lib'

if ARGV.empty?
  puts "Directory name and Depth (default: 1) needed as command-line arguments"
  exit
end

def process_directory(dir_name, regex)
  Dir.glob(File.join(dir_name, "*.[mM][pP]3")).sort.each do |entry|
    fname = File.basename(entry)
    fname =~ regex
    repl     = %|#{"%.2d" % $1.to_i}-#{$2}.mp3|
    puts entry + "\t" + fname + "\t" + repl
  end
end

dir_name = ARGV[0]
depth    = (ARGV[1] || 1).to_i
regex    = %r|^(\d+)\.(.*)\.Mp3$|

puts dir_name, depth

begin
  process_directory(dir_name, regex)
end
