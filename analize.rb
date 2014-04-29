require 'json'
require 'debugger'

tweets = File.read("tweets.csv").split("\n")
words_count = File.read("tweets.csv").split(/\W/).count

stop_words = File.read("common-english-words.txt").split(/\W+/)
dictionary = {}

tweets.each do |tweet|
  words = tweet.split(/\W+/)
  words.each do |word|
    word = word.downcase
    dictionary[word] ||= 0
    dictionary[word] += 1 
  end
end

dictionary = Hash[dictionary.sort_by{|_, v| v}.reverse]

dictionary = dictionary.select do |word, rate|
  word.length > 2 && rate > 3 && !stop_words.include?(word)
end

dictionary.each do |word, rate|
  dictionary[word] = rate.to_f/words_count * 100
end


weight_dictionary = dictionary.clone
puts dictionary.count

weight_dictionary.each{|k,_| weight_dictionary[k] = ""}
f = File.open("words_analyze.json", "w+")
f.write(dictionary.to_json)

fw = File.open("words_weight.json", "w+")
fw.write(weight_dictionary.to_json)