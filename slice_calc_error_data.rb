require 'json'

step_for_file = 1000
collection_dir = "calculate_error"

shuffled_tweets = JSON.parse File.read("#{collection_dir}/shuffled_tweets.json")

# test_collection = File.open("#{collection_dir}/test_collection.json", "w+")
last_file = nil
(shuffled_tweets.count/step_for_file).times do |i|
  count = (i+1) * step_for_file
  file = File.open("#{collection_dir}/#{count}_collection.json", "w+")
  file.write Hash[shuffled_tweets.first(count)].to_json
  last_file = file
end

File.rename(last_file, "#{collection_dir}/test_collection.json")