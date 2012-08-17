#!/usr/bin/env ruby
#
# Download files from Megaupload

# Is the url a valid one?
def valid?(url)
  url =~ %r|^http://www.megaupload.com/\?d=[a-zA-Z0-9]+$|
end

require 'rubygems'
require 'nokogiri'
require 'open-uri'

LinkFile = "megaupload_list.txt"
OutputDirectory = "/home/vikas/downloads/"
TempFile = "/tmp/megaupload-tmp.html"


File.open(LinkFile, 'r') do |f|
  f.each_line do |link|

    link.strip!

    next unless valid?(link)

    begin

      puts "Fetching information for #{link} ..."
      `wget "#{link}" -U "Firefox/4.0.0" --quiet --output-document #{TempFile}`

      doc = Nokogiri::HTML(File.read(TempFile))

      # Filename and Direct Link
      fname = doc.css("div.down_txt_pad1 span.down_txt2").first.content
      direct_link = doc.css("div#downloadlink a").first.attributes['href'].value

      # Actual download
      puts "Downloading #{fname} ... \n"
      `wget -c -P "#{OutputDirectory}" -U "Firefox/3.6.3" "#{direct_link}"`
      puts "*********************************** DONE *******************************************"
      puts "\n\n"

      # Sleep 10 secs. Take some load off megaupload ;)
      sleep 10

    rescue
      puts "ERROR! FileNotFound or otherwise; Skipping this file...."
      puts "\n\n"
      next
    end
  end
end
