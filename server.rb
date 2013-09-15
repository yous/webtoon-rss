require 'sinatra'
require 'json'
require 'open-uri'
require 'nokogiri'

NAVER_URL = 'http://comic.naver.com/webtoon/list.nhn?titleId='

set :bind, '0.0.0.0'

get /^\/naver\/(\d+)/ do |title_id|
	site = open(NAVER_URL + title_id).read
	resp = Nokogiri::HTML(site)
	base_content = resp.at("//div[@id='content']")

	base_info = base_content.at("./div[@class='comicinfo']/div[@class='detail']")
	title_with_writer = base_info.at('./h2')
	title = $1.strip if title_with_writer.inner_html =~ /([^<]+)/
	writer = title_with_writer.at('./span').inner_html.strip
	desc = base_info.at('./p').inner_html.gsub(/\s*<br\s*\/?>\s*/i, "\n")

	JSON.generate({
		title: title,
		writer: writer,
		desc: desc
	})
end
