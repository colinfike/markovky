class Markov < ApplicationRecord

  def self.create_twitter_markov_chain(user)
    return if user.markov_chain != {}
    max_id = user.latest_tweet_seen.to_i
    last_id = nil
    temporary_markov_hash = {}
    post_count = 0

    begin
      logger.info "Looped"
      # curl -H 'Authorization: Bearer AAAAAAAAAAAAAAAAAAAAAPrAxwAAAAAA7UxnoF8EHqFWPexk1DVDXEn0blw%3Dy6F37yvnyfKmbBStx0cFLRAGmSNeqB3Zb3WtvFQeyaUe3cvbvV' 'https://api.twitter.com/1.1/statuses/user_timeline.json?screen_name=colinfike'
      response = RestClient.get("https://api.twitter.com/1.1/statuses/user_timeline.json?screen_name=#{user.twitter_username}#{("&max_id=" + last_id.to_s) if last_id}", {"Authorization" => "Bearer #{ENV["TWITTER_BEARER_TOKEN"]}" })
      parsed_response = JSON.parse(response)
      posts = []
      parsed_response.each do |tweet|
        logger.info "Retweet: #{tweet['retweeted_status']}"
        logger.info "Message: #{tweet['text']}"
        break if tweet['id'] < max_id
        next if !tweet["retweeted_status"].nil?
        last_id = tweet['id'] - 1
        posts << tweet['text']
      end
      logger.info posts
      posts.each do |post|
        temporary_markov_hash = self.process_post(temporary_markov_hash, post)
      end
      post_count = post_count + posts.count
      logger.info "#{post_count} tweets processed."
      # self.analyze_posts(posts)
    end while posts != []

    user.update(markov_chain: temporary_markov_hash)
    # Fetch twitter pages in loop, sending cleaned payloads to analyze_posts
  end

  def analyze_posts posts
  comment_id = nil
  posts["data"]["children"].each do |post|
    comment_id = "t1_" + post["data"]["id"]
    # If the post has not been seen before then process it and mark it as processed so it doesn't analyzed again
    if !@seen_post_ids[comment_id]
      body_text = post["data"]["body"]
      process_post body_text
      @seen_post_ids[comment_id] = 1
    end
    puts @seen_post_ids.count
  end

  # Save data to pstore
  @data_store.transaction do
    @data_store["markov_data"] = @markov_data
    @data_store["seen_post_ids"] = @seen_post_ids
  end
  return comment_id
  puts 'analyze_posts'
end
#
# # Strips out garbage text and iterates over each word
def self.process_post temporary_markov_hash, post
  past_word = '['
  current_word = '['
  post.split('.!?').select{|x| (x[0] != '@') && (!x.include?('http'))}.each_with_index do |sentence, index|
    # Converts html entity names back to their actual ASCII values, removes returns and all non-alphanumeric values (and spaces)
    word_array = CGI::unescapeHTML(sentence).gsub(/\n/, "").gsub(/[^A-Za-z@# ]/, '').split(' ')
    word_count = word_array.count
    logger.info word_array

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
#
def self.generate_sentence(user)
  chosen_word = "["
  sentence = ""
  while chosen_word != "]"
    word_hash = user.markov_chain[chosen_word]
    randomizer = WeightedRandomizer.new(word_hash)
    chosen_word = randomizer.sample
    sentence << chosen_word + " " if chosen_word != "]"
  end
  puts sentence.downcase.capitalize.chomp(' ') + "."
end
# end
end
