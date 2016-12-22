class Markov < ApplicationRecord

  def self.create_twitter_markov_chain(user)
    return if user.markov_chain != {}
    max_id = user.latest_tweet_seen.to_i
    last_id = nil
    temporary_markov_hash = {}
    post_count = 0

    begin
      response = RestClient.get("https://api.twitter.com/1.1/statuses/user_timeline.json?screen_name=#{user.twitter_username}#{("&max_id=" + last_id.to_s) if last_id}", {"Authorization" => "Bearer #{TWITTER_BEARER_TOKEN}" })
      parsed_response = JSON.parse(response)
      posts = []
      parsed_response.each do |tweet|
        break if tweet['id'] < max_id
        next if !tweet["retweeted_status"].nil?
        last_id = tweet['id'] - 1
        posts << tweet['text']
      end
      posts.each do |post|
        temporary_markov_hash = self.process_post(temporary_markov_hash, post)
      end
      post_count = post_count + posts.count
    end while posts != []

    user.update(markov_chain: temporary_markov_hash)
  end

  # # Strips out garbage text and iterates over each word
  def self.process_post temporary_markov_hash, post
    past_word = '['
    current_word = '['
    # Remove links then tear everything apart at terminal points
    post.gsub(/http\S+/, '').split('.!?').each_with_index do |sentence, index|
      # Converts html entity names back to their actual ASCII values, removes returns and all non-alphanumeric values (and spaces)
      word_array = CGI::unescapeHTML(sentence).gsub(/\n|[^A-Za-z@# ]|@\w+/,'').split(' ')
      word_count = word_array.count

      word_array.each_with_index do |word, current_word_index|
        past_word = current_word
        current_word = word
        # Increment the count of the current_word key's value in past_word hash
        temporary_markov_hash[past_word] = {} if !temporary_markov_hash[past_word]
        temporary_markov_hash[past_word][current_word] = temporary_markov_hash[past_word][current_word].to_i + 1

        # If this is the last word in the sentence then take the current word and increment the BOL key's value.
        temporary_markov_hash[current_word] = {} if !temporary_markov_hash[current_word]
        temporary_markov_hash[current_word][']'] = temporary_markov_hash[current_word][']'].to_i + 1 if current_word_index == word_count - 1
      end
    end
    return temporary_markov_hash
  end

  def self.generate_sentence(user)
    return false if user.markov_chain.blank?
    chosen_word = "["
    sentence = ""
    while chosen_word != "]"
      word_hash = user.markov_chain[chosen_word]
      randomizer = WeightedRandomizer.new(word_hash)
      chosen_word = randomizer.sample
      sentence << chosen_word + " " if chosen_word != "]"
    end
    return sentence.downcase.capitalize.chomp(' ') + "."
  end
end
