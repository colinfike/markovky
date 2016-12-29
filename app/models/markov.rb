class Markov < ApplicationRecord

  def self.create_twitter_markov_chain(user, depth = 1)
    # return if user.markov_chain != {}
    max_id = user.latest_tweet_seen.to_i
    last_id = nil
    temporary_markov_hash = {}
    post_count = 0

    # begin
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
    # rescue => e
    #   logger.info "Error during tweet fetch: #{e}"
    # end
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
        # If this is the last word in the sentence then take the current word and increment the BOL key's value.
        # temporary_markov_hash[current_word] = {} if !temporary_markov_hash[current_word]
        # temporary_markov_hash[current_word][']'] = temporary_markov_hash[current_word][']'].to_i + 1 if current_word_index == word_count - 1
      end
    end
    return temporary_markov_hash
    # Outline
    # 1) Dictionary will be a hash of hashes of hashes
    # 2) The first hash will have key:first_word and value:hash
    # 3) The second hash will have key:second_word and value:hash
    # 4) The third hash will have key:next_word and value:number_of_times_seen_after_preceding_two_words
    # Reading posts
    # 2) 2+ words? Easy. First word is [. Second word is the first real word. Next word is the second real word, increment counter by 1. Go to the first real word and continue if there are two more words following it, otherwise end.
    # 3) 1+ words? Easy. First word is [. Second word is the first real word. Next word is ], increment counter by 1
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
