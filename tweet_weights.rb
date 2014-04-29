require 'json'
require 'debugger'
require 'active_support/inflector'

def normalize_weight(weight)
  weight.to_f/5
end

@hash_dictionary = {}

@dictionary = File.read("interesting_words.txt")
@dictionary.split("\n").each do |word_with_weight|
  word_with_weight = word_with_weight.split("\t")
  word = word_with_weight[0]
  weight = normalize_weight(word_with_weight[1].to_i)
  @hash_dictionary[word] = weight
end

result_dictionary = {}

def tweet_weight(tweet)
  tweet_code = Array.new(@hash_dictionary.length, 0)
  matched_words = 0
  weight = 0.0
  words = tweet.split(/\W+/)
  words.each_with_index do |w, index| 
    tw = @hash_dictionary[w].to_f
    if tw != 0.0 && tw != nil 
      weight += tw
      tweet_code[index] = 1
      matched_words += 1
    end
  end
  result_weight = weight/matched_words
  {code: tweet_code.join, weight: result_weight.nan? ? 0 : result_weight} 
end

tweets = File.read("tweets.csv").split("\n")

tweets.each do |tweet|
  words = tweet.split(/\W+/).map do |word|
    word = word.gsub(/(\w+:\/\/\S+|#)/, "")
    word.downcase
  end
  tweet = words.join(" ")

  result_dictionary[tweet] = tweet_weight(tweet)
  puts result_dictionary[tweet] if result_dictionary[tweet][:weight] != 0
end

f = File.open("tweets_analyze.json", "w+")
f.write(result_dictionary.to_json)
