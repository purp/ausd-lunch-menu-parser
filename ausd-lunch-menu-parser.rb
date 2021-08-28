#!/usr/bin/env ruby
require 'nokogiri'
require 'open-uri'
require 'pdf-reader'
require 'final_redirect_url'

menu_page = Nokogiri::HTML(URI.open('https://bit.ly/ausd-school-lunch-menus'))

menu_links = menu_page.css('div.interactivemenuswrapper table tr td div a').select do |link|
    link['href'].match(/downloadMenu.php/)
end

menu_links.select {|link| link['href'].match(/downloadMenu.php/)}.each do |link|
    menu_url = 'https://www.schoolnutritionandfitness.com' + link['href']
    puts ">>> MENU URL: #{menu_url}"
    final_menu_url = FinalRedirectUrl.final_redirect_url(menu_url)
    puts ">>> FINAL MENU URL: #{final_menu_url}"
    menu_pdf = URI.open(final_menu_url)
    menu_doc = PDF::Reader.new(menu_pdf)
    puts menu_doc.info
    puts menu_doc.text
end
