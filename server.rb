require 'lib/webtoon'
require 'sinatra'

set :bind, '0.0.0.0'

get /^\/naver\/(\d+)/ do |title_id|
	NaverWebtoon.new(title_id).get
end
