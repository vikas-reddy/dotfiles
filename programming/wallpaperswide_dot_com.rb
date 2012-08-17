#!/usr/bin/env ruby
#
#  Vikas Reddy
#
#  A little script to download ALL the wallpapers of a given
#  resolution from http://www.wallpaperswide.com/
#
#  Requirements
#  ============
#  Ruby Version: 1.9.2
#  Gems: nokogiri, open-uri
#  Other programs: wget
#
#
#  Available Resolutions
#  =====================
#
#  Wide
#  
#  * 16:10 960x600
#  * 16:10 1152x720
#  * 16:10 1280x800
#  * 16:10 1440x900
#  * 16:10 1680x1050
#  * 16:10 1920x1200
#  * 16:10 2560x1600
#  * 16:10 3840x2400
#  * 16:10 5120x3200
#  * 5:3 800x480
#  * 5:3 1280x768
#  
#  HD
#  
#  * 16:9 960x540
#  * 16:9 1024x576
#  * 16:9 1280x720
#  * 16:9 1366x768
#  * 16:9 1600x900
#  * 16:9 1920x1080
#  * 16:9 2048x1152
#  * 16:9 2400x1350
#  * 16:9 2560x1440
#  * 16:9 3554x1999
#  * 16:9 3840x2160
#  
#  Standard
#  
#  * 4:3 800x600
#  * 4:3 1024x768
#  * 4:3 1152x864
#  * 4:3 1280x960
#  * 4:3 1400x1050
#  * 4:3 1440x1080
#  * 4:3 1600x1200
#  * 4:3 1680x1260
#  * 4:3 1920x1440
#  * 4:3 2048x1536
#  * 4:3 2560x1920
#  * 4:3 2800x2100
#  * 4:3 3200x2400
#  * 4:3 4096x3072
#  * 5:4 1280x1024
#  * 5:4 2560x2048
#  * 5:4 3750x3000
#  
#  Mobile Ratio
#  
#  * VGA 240x320
#  * VGA 480x640
#  * VGA 320x240
#  * VGA 640x480
#  * WVGA 240x400
#  * WVGA 480x800
#  * WVGA 400x240
#  * WVGA 800x480
#  * HVGA 320x480
#  * HVGA 480x320
#  * HVGA 640x960
#  * HVGA 960x640
#  * iPad 1024x768
#  * iPad 768x1024
#  * HD 16:9 480x272
#  * HD 16:9 272x480
#  * Phone 176x220
#  * Phone 220x176
#  
#  Dual
#  
#  * 4:3 1600x600
#  * 4:3 2048x768
#  * 4:3 2304x864
#  * 4:3 2560x960
#  * 4:3 2800x1050
#  * 4:3 2880x1080
#  * 4:3 3200x1200
#  * 4:3 3360x1260
#  * 4:3 3840x1440
#  * 4:3 4096x1536
#  * 4:3 5120x1920
#  * 4:3 5600x2100
#  * 4:3 6400x2400
#  * 4:3 8192x3072
#  * 5:4 2560x1024
#  * 5:4 5120x2048
#  * 5:4 7500x3000
#  * 5:4 10240x4096
#  * 16:10 1920x600
#  * 16:10 2304x720
#  * 16:10 2560x800
#  * 16:10 2880x900
#  * 16:10 3360x1050
#  * 16:10 3840x1200
#  * 16:10 5120x1600
#  * 16:10 7680x2400
#  * 16:10 10240x3200
#  * 5:3 1600x480
#  * 5:3 2560x768
#  * 16:9 1920x540
#  * 16:9 2048x576
#  * 16:9 2560x720
#  * 16:9 3200x900
#  * 16:9 3840x1080
#  * 16:9 4096x1152
#  * 16:9 4800x1350
#  * 16:9 5120x1440
#  * 16:9 7108x2000
#  * 16:9 7680x2160
#  * 3:2 2880x960
#  * 3:2 4000x1333
#  * 3:2 2304x768
#  
#  Other
#  
#  * 3:2 1152x768
#  * 3:2 1440x960
#  * 3:2 2000x1333


require 'open-uri'
require 'nokogiri'

Resolution = "1600x900"
Base_URL   = "http://wallpaperswide.com/#{Resolution}-wallpapers-r/page/"
Output_Directory = "/home/vikas/Wallpapers/"

# Create the Output_Directory if needed
`mkdir -p "#{Output_Directory}"`

(1..2492).each do |page_num|

  # Go page by page
  url = Base_URL + page_num.to_s

  # Parse html
  f = open(url)
  doc = Nokogiri::HTML(f)

  # Loop over image-boxes
  doc.css("div.thumb").each do |wallp|

    # Extract wallpaper subpage url
    wallp.css("div[onclick]").attr("onclick").value =~ /prevframe_show\('(.*)'\)/
    subpage_url = $1
    subpage_url =~ %r|http://wallpaperswide\.com/[^/]+/([\w\d]+)\.html|

    # Generate url of the required wallpaper
    wallp_url = %|http://wallpaperswide.com/download/#{$1}-#{Resolution}.jpg|
    
    # Download... with a user-agent parameter just in case...
    # use '--limit-rate=100k' to limit download speed
    `wget -c -U "Firefox/4.5.6" -P "#{Output_Directory}" "#{wallp_url}"`
  end
end
