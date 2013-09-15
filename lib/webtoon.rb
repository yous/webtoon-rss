require 'open-uri'
require 'nokogiri'
require 'json'

class Webtoon
	private
	def open_site url
		site = open(url).read
		resp = Nokogiri::HTML(site)

		fixed_site = site.split("\n")
		resp.errors.each do |error|
			if error.message =~ /^htmlParseStartTag/
				fixed_site[error.line - 1].gsub!(/^([\w\W]{#{error.column - 2}})(<)([^>]*)(>)/, '\1&lt;\3&gt;')
			end
		end

		fixed_site.join("\n")
	end
end

class NaverWebtoon < Webtoon
	@@url = 'http://comic.naver.com/webtoon/list.nhn?titleId='

	def initialize title_id
		@title_id = title_id
		@url = @@url + @title_id
		@data = nil
		parse
	end

	def get
		@data
	end

	private
	def parse
		resp = Nokogiri::HTML(open_site(@url))
		base_content = resp.at("//div[@id='content']")

		base_info = base_content.at("./div[@class='comicinfo']/div[@class='detail']")
		title_with_writer = base_info.at('./h2')
		title = $1.strip if title_with_writer.inner_html =~ /([^<]+)/
		writer = title_with_writer.at('./span').inner_html.strip
		desc = base_info.at('./p').inner_html.gsub(/\s*<br\s*\/?>\s*/i, "\n")

		comics = []
		base_content.search("./table[@class='viewList']/tr").each do |tr|
			next if tr.search("./td[@class='blank']").length > 0
			comic_title = tr.at("./td[@class='title']/a").inner_html.strip
			rating = tr.at("./td[3]/div[@class='rating_type']/strong").inner_html.strip
			date = tr.at('./td[4]').inner_html.strip
			comics << {
				title: comic_title,
				rating: rating,
				date: date
			}
		end

		@data = JSON.generate({
			title: title,
			writer: writer,
			desc: desc,
			comics: comics
		})
	end
end
