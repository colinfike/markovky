class MarkovController < ApplicationController
  def fetch_twitter_chain
    # Whole section with error handling is a mess but it prevents some unenecessary saves of the object
    # if I did it a bit cleaner. I cut down on code duplication but I don't think that may be a good thing in this case.
    # TODO: Remove @ from username if it's the first character
    # TODO: Add warning if you dont have enough tweets
    error = nil
    user = User.find_or_create_by(twitter_username: params[:twitter_username])
    Markov.create_twitter_markov_chain(user) if user.user_chain.nil?
    sentence = Markov.generate_sentence(user) if !user.user_chain.nil?
    error = "Twitter user is private or invalid" if !user.errors.messages.empty? || sentence == false || user.user_chain.nil?
    respond_to do |format|
      format.html
      format.json { render json: {:sentence => sentence, :error => error} }
    end
  end

  def fetch_word_map
    # {text: "Lorem", weight: 13},
    @json_payload = []
    User.last.user_word_map.word_map.each do |k,v|
      @json_payload << { "text" => k, "weight" => v }
    end
  end

  private
    def markov_params
      params.require(:user).permit(:twitter_username)
    end
end
