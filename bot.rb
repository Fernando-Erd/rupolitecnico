require "rubygems"
require "em-http-request"
require "simple_oauth"
require "json"
require "uri"
require 'open-uri'
require 'nokogiri'
require 'twitter'

# config oauth
OAUTH = {
 :consumer_key => "", 		#Consumer key generate by twitter
 :consumer_secret => "", 	#Consumer Secret generate by twitter
 :token => "", 			#Token generate by twitter
 :token_secret => "" 		#Token Secret generate by twitter
}

client = Twitter::REST::Client.new do |config|
 config.consumer_key       = OAUTH[:consumer_key]
 config.consumer_secret    = OAUTH[:consumer_secret]
 config.access_token        = OAUTH[:token]
 config.access_token_secret = OAUTH[:token_secret]
end

client_stream = Twitter::Streaming::Client.new do |config|
 config.consumer_key       = OAUTH[:consumer_key]
 config.consumer_secret    = OAUTH[:consumer_secret]
 config.access_token        = OAUTH[:token]
 config.access_token_secret = OAUTH[:token_secret]
end

@periods = {
  "breakfast" => 3,
  "lunch" => 4,
  "dinner" => 5
}

def getMenu(period, day, month)
    url = 'http://www.pra.ufpr.br/portal/ru/ru-centro-politecnico/'
    doc = Nokogiri::HTML(open(url))
    doc.encoding = 'utf-8'
    html_text = []
    doc.css('p, h1').each do |e|  
      	a = e.content.encode("iso-8859-1").force_encoding("utf-8")
      	html_text.push(a)
    end
    if ((html_text[2].include? day.to_s) && (html_text[2].include? month.to_s))
      	return html_text[2] + +"\n" + html_text[@periods[period]]
    elsif (html_text[6].include? day.to_s)
      	return html_text[6] + "\n" + html_text[@periods[period]+4]
    elsif (html_text[7].include? day.to_s)
      	return html_text[7] + "\n" + html_text[@periods[period]+5]
    else
        return "O Cardápio não foi atualizado no site"
    end
end

time = Time.new
getMenu("breakfast", time.day, time.mon)
if (time.hour == 6)
    client.update(getMenu("breakfast", time.day, time.mon))
elsif (time.hour == 9)
    client.update(getMenu("lunch", time.day, time.mon))
elsif (time.hour == 16)
    client.update(getMenu("dinner", time.day, time.mon))
end
