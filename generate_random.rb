require 'json'
require 'byebug'
Words = File.read "interesting_words.txt"
Words = Words.split("\n")
Words = Words.map{|w| w.split("\t")} 
Words = Hash[Words]
Tweets = JSON.parse(File.read("calculate_error/shuffled_tweets.json")).to_a

def normalize_weight(weight)
  weight.to_f/5
end

def sentance_code(sentance)
  code = Array.new(144){0}
  sentance_words = sentance.split(/\W/)
  sentance_words.each do |word|
    code[Words.keys.index(word)] = 1
  end
  code.map(&:to_s).join
end

def sentance_weight(sentance)
  weight = 0.0
  sentance_words = sentance.split(/\W/)
  sentance_words.each do |word|
    weight += Words[word].to_f
  end

  normalize_weight(weight/sentance_words.count)
end


12000.times do 
  new_sentance = Words.keys.shuffle.first(rand(1..11)).join(" ")
  Tweets << [new_sentance, {code: sentance_code(new_sentance), weight: sentance_weight(new_sentance)}]
end

Tweets = Tweets.uniq{|el| el[1]["code"]}

f = File.open("calculate_error/shuffled_tweets.json", "w+")
f.write Hash[Tweets].to_json