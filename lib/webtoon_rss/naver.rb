require 'builder'

module WebtoonRSS
  class Naver < Site
    BASE_URL = 'http://comic.naver.com'

    def initialize title_id
      @title_id = title_id
      @url = "#{BASE_URL}/webtoon/list.nhn?titleId=#{@title_id}"
      @data = nil
      parse
    end

    def url
      @url
    end

    def get
      xml = Builder::XmlMarkup.new
      xml.instruct! :xml, version: '1.0'
      xml.rss version: '2.0' do
        xml.channel do
          xml.title @data[:title]
          xml.description @data[:desc]
          xml.link @url

          @data[:comics].each do |comic|
            xml.item do
              xml.title comic[:title]
              xml.pubDate comic[:date]
              xml.link comic[:link]
              xml.guid comic[:link]
            end
          end
        end
      end
    end

    private
    def parse
      resp = Nokogiri::HTML(read)
      base_content = resp.at("//div[@id='content']")

      base_info = base_content.at("./div[@class='comicinfo']/div[@class='detail']")
      title_with_writer = base_info.at('./h2')
      title = $1.strip if title_with_writer.inner_html =~ /([^<]+)/
      writer = title_with_writer.at('./span').inner_html.strip
      desc = base_info.at('./p').inner_html.gsub(/\s*<br\s*\/?>\s*/i, "\n")

      comics = []
      base_content.search("./table[@class='viewList']/tr").each do |tr|
        next if tr.search("./td[@class='blank']").length > 0
        comic_title_link = tr.at("./td[@class='title']/a")
        comic_title = comic_title_link.inner_html.strip
        link = comic_title_link.attr('href')
        link = "#{BASE_URL}#{link}" if link =~ /^\//
        rating = tr.at("./td[3]/div[@class='rating_type']/strong").inner_html.strip
        date = Time.parse(tr.at('./td[4]').inner_html.strip).rfc822
        comics << {
          title: comic_title,
          link: link,
          rating: rating,
          date: date
        }
      end

      @data = {
        title: title,
        writer: writer,
        desc: desc,
        comics: comics
      }
    end
  end
end
