#!/usr/bin/env ruby

require 'rubygems'
require 'nokogiri'
require 'open-uri'

Resolution = "1400x1050"
Domain   = "http://interfacelift.com"
BaseLink = "http://interfacelift.com/wallpaper_beta/downloads/date/fullscreen/#{Resolution}/"
OutputDirectory = "wallpapers" #_#{Resolution}/"


(1..223).each do |num|
  doc = Nokogiri::HTML(
    open("#{BaseLink}index#{num}.html", {'User-Agent' => 'Firefox/3.6.3'})
  )

  doc.css('div.download > div > a').each do |link|
    uri = link.attributes['href'].value
    url = Domain + uri
    `wget -c -P "#{OutputDirectory}" -U "Firefox/3.6.3" "#{url}"`
    #puts %Q{wget -c -P "#{OutputDirectory}" "#{url}"}
  end

  puts "********************************************************************************"
  puts "******************************** #{num} done ***********************************"
  puts "********************************************************************************"
end
