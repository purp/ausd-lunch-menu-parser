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

    # Menus are always 1 page and use returns and spaces for layout and have a few strange chars
    # as well, so we clean things up
    lines = menu_doc.pages.first.text.split(/(?:\n|\r)+/).reject(&:empty?)
    lines.each do |line|
        line.encode!(Encoding.find('ASCII'), :undef => :replace, :replace => '')
        line.rstrip!
    end

    # Second line is usually the menu title (Elementary or Secondary)
    school = lines[1].capitilize

    # Third line has month and year
    month, year = lines[2].match(/\bmenu\s+(?<month>\S+)\s+(?<year>\d+)).captures
    month.capitalize!

    # Fourth line is names of weekdays. I think we know those, and they don't change much.

end
