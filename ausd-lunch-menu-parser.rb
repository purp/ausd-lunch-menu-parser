#!/usr/bin/env ruby
require 'nokogiri'
require 'open-uri'
require 'pdf-reader'

menu_page = Nokogiri::HTML(URI.open('https://bit.ly/ausd-school-lunch-menus'))

menu_links = menu_page.css('div.interactivemenuswrapper table tr td h3 div a')

puts menu_links
