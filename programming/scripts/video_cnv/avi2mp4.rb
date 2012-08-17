#!/usr/bin/ruby

=begin

5230:
  MPEG4-SP playback 30fps VGA
  MPEG4-AVC playback 30fps QVGA
  WMV9 playback 30fps QVGA
  MPEG4-SP playback 30 fps nHD

=end


ARGV.each do |input_f|
  everything_ok = true
  log_file = "divx2pass.log"

  # Escapes single quotes
  input_f = input_f.split("'").join("\'\\'\'")

  # Extracts the file name without extension
  file_name = input_f.split(".")[0..-2].join(".")  

  # Output file
  output_f = file_name + ".mp4"
  puts "\nConverting \'#{input_f}\' into \'#{output_f}\':"

  # Check if there are subtitles to add to the file
  subs_args = '' #File.exists?(file_name + ".srt") ? " -sub \'#{file_name}.srt\'" : ""

  # Encodes with two pass
  [":vpass=1:turbo",":vpass=2"].each do |vpass|
    command = "mencoder"
    command << " -of lavf -lavfopts format=mp4" # Set container format to mp4
    command << " -oac lavc" # Audio will be encoded with a libavcodec codec
    command << " -ovc lavc" # Video will be encoded with a libavcodec codec

    command << " -lavcopts" # Begin of options for libavcodec
    command << " aglobal=1:vglobal=1" # Needed for mp4
    command << ":acodec=libfaac" # Encode audio as AAC
    command << ":vcodec=mpeg4" # Encode video as mp4 too
    command << ":abitrate=96" # Audio bitrate in Kbps
    command << ":vbitrate=700" # Video bitrate in Kbps
    command << ":keyint=250" # Number of frames between keyframes, a bit lower than the default to save some Megabytes
    command << ":mbd=1" # Macroblock decision algorithm set to minimize size of file
    command << ":vqmax=10:lmax=10" # Don't know whay but raises the video quality
    command << vpass # First pass or second pass

    command << " -ofps 25" # Convert the video to 25 fps to avoid incompatible fps values
    command << " -af lavcresample=44100" # Resample the audio
    command << " -vf harddup,scale=640:-3" # Scale the video to 640 px width mantaining aspect ratio
    command << subs_args # Add subs

    # command << " -endpos 10" # Encode just the first 10 seconds of video, useful for testing

    command << " \'#{input_f}\' -o \'#{output_f}\'" # file names

    puts command
    everything_ok = system command

    if !everything_ok
      puts "There were errors encoding #{input_f}, aborting."
      break
    end
  end

  File.delete log_file if File.exists? log_file
  puts "File succesfully encoded as \'#{output_f}\'" if everything_ok
end
