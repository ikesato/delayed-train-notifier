# -*- coding: utf-8 -*-
require 'open-uri'
require 'nokogiri'

class YahooTransit
  URL = "http://transit.yahoo.co.jp/traininfo/area/4/"

  def scrape(url=URL)
    doc = fetch(url)
    list = []
    doc.css('.elmTblLstLine.trouble a').each do |a|
      detail = fetch(a[:href])
      name = detail.css('h1').text.strip
      time = detail.css('.subText').text.strip
      description = detail.css('.trouble').text.strip
      next if name.empty? || time.empty? || description.empty?
      next if time !~ /(\d+)月(\d+)日 (\d+)時(\d+)分更新/
      time = Time.local(Time.now.year, $1.to_i, $2.to_i, $3.to_i, $4.to_i)
      list << {name: name, time: time, description: description, url: a[:href]}
    end
    list
  end

  private
  def fetch(url)
    charset = nil
    html = open(url) do |f|
      charset = f.charset if url =~ /^http/
      f.read
    end
    doc = Nokogiri::HTML.parse(html, nil, charset)
  end
end
