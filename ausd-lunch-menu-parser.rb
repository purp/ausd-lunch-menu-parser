#!/usr/bin/env ruby
require 'nokogiri'
require 'open-uri'
require 'pdf-reader'
require 'final_redirect_url'

menu_page = Nokogiri::HTML(URI.open('https://bit.ly/ausd-school-lunch-menus'))

menu_links = menu_page.css('div.interactivemenuswrapper table tr td div a').select do |link|
    link['href'].match(/downloadMenu.php/)
end

menu_links.map {|elem| FinalRedirectUrl.final_redirect_url('https://www.schoolnutritionandfitness.com' + elem['href'])}.each do |menu_url|
    puts ">>> MENU URL: #{menu_url}"
    menu_pdf = URI.open(menu_url)
    menu_doc = PDF::Reader.new(menu_pdf)
    puts menu_doc.info
    puts menu_doc.pages.size
    puts menu_doc.pages.first.text
end
