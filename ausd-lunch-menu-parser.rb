#!/usr/bin/env ruby
require 'nokogiri'
require 'open-uri'
require 'pdf-reader'

menu_page = Nokogiri::HTML(URI.open('https://bit.ly/ausd-school-lunch-menus'))

menu_links = menu_page.css('div.interactivemenuswrapper table tr td div a').select do |link|
    link['href'].match(/downloadMenu.php/)
end

menu_links.select {|link| link['href'].match(/downloadMenu.php/)}.each do |link|
    menu_url = 'https://www.schoolnutritionandfitness.com/' + link['href']
    puts ">>> MENU URL: #{menu_url}"
    menu_pdf = URI.open(menu_url)
    menu_doc = PDF::Reader(menu_pdf)
    puts menu_doc.info
end
