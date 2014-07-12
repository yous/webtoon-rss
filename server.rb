require 'webtoon_rss'
require 'sinatra'

set :bind, '0.0.0.0'

before do
  content_type 'text/xml'
end

get /^\/naver\/(\d+)/ do |title_id|
  WebtoonRSS::Naver.new(title_id).get
end
