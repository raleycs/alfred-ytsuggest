require 'cgi'
require 'json'
require 'net/http'
require 'uri'

Seed = ENV['uid_seed'] || Time.now.to_s

def new_result(name)
  {
    uid: "#{Seed} #{name}",
    title: name,
    subtitle: "Search “#{name}” on YouTube",
    arg: name
  }
end

script_filter_items = []

script_filter_items.push(new_result(ARGV[0]))

if ARGV[0] != ENV['current_arg']
  ENV['results']&.split("\n")&.first(8)&.each do |result| script_filter_items.push(new_result(result)) end

  puts({
    rerun: 0.1,
    variables: { results: ENV['results'], current_arg: ARGV[0], uid_seed: Seed },
    items: script_filter_items
  }.to_json)

  exit 0
end

Encoded = CGI.escape(ARGV[0])
Query_url = "http://suggestqueries.google.com/complete/search?client=firefox&ds=yt&q=#{Encoded}"
Results = JSON.parse(Net::HTTP.get(URI.parse(Query_url)).force_encoding('iso-8859-1').encode('utf-8'))[1]

Results.reject { |result| result == ARGV[0] }.first(8).each do |result| script_filter_items.push(new_result(result)) end

puts({
  variables: { results: Results.join("\n"), current_arg: ARGV[0], uid_seed: Seed },
  items: script_filter_items
}.to_json)
