require 'yaml'
require 'oauth'
require 'json'
require 'uri'
require 'net/http'

conf = YAML.load_file('../../conf.yml')
puts conf

CONSUMER_KEY = conf['consumer_key']
CONSUMER_SECRET = conf['consumer_secret']
RESOURCE = '/' << conf['team'] << '/' << conf['repository']
INCOMING_WEBHOOK_URL = conf['incoming_webhook_url']

SITE = 'https://bitbucket.org'
REQUEST = '/api/1.0/repositories'<< RESOURCE << '/issues?status=resolved'
SLACK_URL = URI.parse(INCOMING_WEBHOOK_URL)

def form_post_message (issues)
	text = "今週の進捗報告\n"
	issues.each do |issue|
		title = issue['title']
		local_id = issue['local_id'].to_s
		last_updated = Time.parse(issue['utc_last_updated']).to_s
		text <<
				'<' <<SITE << RESOURCE << '/issue/' << local_id << '/' << URI.encode_www_form_component(title) << '|' << title << '>' <<
				" :\t" << last_updated <<
				"\n"
	end
	text
end

# OAuth
consumer = OAuth::Consumer.new CONSUMER_KEY, CONSUMER_SECRET, :site => SITE

access_token = OAuth::AccessToken.new(consumer)

# Bitbucketからデータを取得
response = access_token.request(:get, REQUEST)

issues = JSON.parse(response.body)

# 解決されて一週間以内のissueを取り出す
selected = issues['issues'].select do |issue|
	(Time.parse(issue['utc_last_updated']) <=> Time.now - 60 * 60 * 24 * 7) >= 0
end

# 解決された日時順にソート
sorted = selected.sort_by { |issue| issue['utc_last_updated'] }

# 取得したデータを元にSlackに投稿するテキストを生成する
text = form_post_message(sorted)

# Slackにhttp通信する
# 参考：http://shirusu-ni-tarazu.hatenablog.jp/entry/2012/07/02/023326
request = Net::HTTP::Post.new(SLACK_URL.request_uri, initheader = {'Content-Type' => 'application/json'})
request.body = {
		text: text,
		username: 'Shinchoku Reporter'
}.to_json

http = Net::HTTP.new(SLACK_URL.host, SLACK_URL.port)
http.use_ssl = true
http.verify_mode = OpenSSL::SSL::VERIFY_NONE

http.set_debug_output $stderr

http.start do |h|
	response = h.request(request)
end