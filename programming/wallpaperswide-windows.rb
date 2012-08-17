require 'open-uri'
require 'nokogiri'

Resolution = "1600x900"
Base_URL   = "http://wallpaperswide.com/#{Resolution}-wallpapers-r/page/"
Output_Directory = "C:\\Wallpapers"


(1..2805).each do |page_num|

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
    system(%|"C:\\Program Files\\GnuWin32\\bin\\wget.exe" -c -U "Firefox/4.5.6" -P "#{Output_Directory}" "#{wallp_url}"|)

  end
end
