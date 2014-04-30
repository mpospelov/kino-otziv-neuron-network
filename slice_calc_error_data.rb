require 'json'

step_for_file = 1000
collection_dir = "calculate_error"

shuffled_tweets = JSON.parse File.read("#{collection_dir}/shuffled_tweets.json")
last_shuffled_tweets = shuffled_tweets.to_a.last(step_for_file)
shuffled_tweets = Hash[shuffled_tweets.to_a - last_shuffled_tweets]
puts shuffled_tweets.count
puts last_shuffled_tweets.count

test_collection = File.open("#{collection_dir}/test_collection.json", "w+")
test_collection.write Hash[last_shuffled_tweets].to_json

(shuffled_tweets.count/step_for_file).times do |i|
  count = (i+1) * step_for_file
  file = File.open("#{collection_dir}/#{count}_collection.json", "w+")
  file.write Hash[shuffled_tweets.first(count)].to_json
end