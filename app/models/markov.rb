class Markov < ApplicationRecord

  def self.create_twitter_markov_chain(user, depth = 1)
    max_id = user.latest_tweet_seen.to_i
    last_id = nil
    temporary_markov_hash = {}
    post_count = 0

    begin
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
        posts.each{|post| temporary_markov_hash = self.process_post(temporary_markov_hash, post)}
        post_count = post_count + posts.count
      end while posts != []
    rescue => e
      logger.info "Error during tweet fetch: #{e}"
    end
    user.update(markov_chain: temporary_markov_hash)
  end

  # # Strips out garbage text and iterates over each word
  def self.process_post temporary_markov_hash, post
    past_word = '['
    current_word = '['
    next_word = nil
    # Remove links then tear everything apart at terminal points
    # TODO: Pull this out into a method
    post.gsub(/http\S+/, '').split('.!?').each_with_index do |sentence, index|
      # Converts html entity names back to their actual ASCII values, removes returns and all non-alphanumeric values (and spaces)
      # TODO: Pull this out into a method
      # NOTE: Could downcase here potentially
      word_array = CGI::unescapeHTML(sentence).gsub(/\n|[^A-Za-z@# ]|@\w+/,'').split(' ')
      word_count = word_array.count

      word_array.each_with_index do |word, current_word_index|
        past_word = current_word
        current_word = word
        next_word = current_word_index == word_count - 1 ? ']' : word_array[current_word_index + 1]

        # Increment the count of the current_word key's value in past_word hash
        temporary_markov_hash[past_word] = {} if !temporary_markov_hash[past_word]
        temporary_markov_hash[past_word][current_word] = {} if !temporary_markov_hash[past_word][current_word]
        temporary_markov_hash[past_word][current_word][next_word] = temporary_markov_hash[past_word][current_word][next_word].to_i + 1
        break if next_word == ']'
      end
    end
    return temporary_markov_hash
  end

  def self.generate_sentence(user)
    logger.info '45'
    return false if user.markov_chain.blank?
    logger.info '46'
    # First part of the sentence
    word_hash = {}
    user.markov_chain['['].each do |k,v|
      v.each do |k2, v2|
        word_hash["#{k} #{k2}"] = v2
      end
    end
    randomizer = WeightedRandomizer.new(word_hash)
    chosen_word = randomizer.sample

    if chosen_word.split[1] == ']'
      return chosen_word.split.first + '.'
    else
      sentence = ""
      sentence << chosen_word
      # Maybe make this recursive
      split_sentence = sentence.split
      while split_sentence.last != ']'
        break if user.markov_chain[split_sentence[-2]].nil?
        randomizer_hash = user.markov_chain[split_sentence[-2]][split_sentence[-1]]
        randomizer = WeightedRandomizer.new(randomizer_hash)
        chosen_word = randomizer.sample
        sentence << " " + chosen_word
        split_sentence = sentence.split
      end
      return sentence.gsub(' ]','').capitalize + '.'
    end
  end

  private
    def clean_split_post(post)
      cleaned_post = post.gsub(/http\S+/, '').split('.!?')
    end
end
