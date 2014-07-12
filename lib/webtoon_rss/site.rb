require "open-uri"

module WebtoonRSS
  class Site
    def self.site_name
      name.split("::").last.downcase
    end

    def url
      ""
    end

    private
    def read
      site = URI.parse(url).open.read
      resp = Nokogiri::HTML(site)

      fixed_site = site.split("\n")
      resp.errors.reverse.each do |error|
        next unless error.message =~ /^htmlParseStartTag/
        fixed_site[error.line - 1].gsub!(/^([\w\W]{#{error.column - 2}})(<)([^>]*)(>)/, "\\1&lt;\\3&gt;")
      end

      fixed_site.join("\n")
    end
  end
end
