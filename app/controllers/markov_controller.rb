class MarkovController < ApplicationController
  def index
    @user = User.new
  end

  def fetch_twitter_chain
    user = User.find_or_create_by(markov_params)
    Markov.create_twitter_markov_chain(user)
    @sentence = Markov.generate_sentence(user)
    logger.info "Sentence: #{@sentence}"
  end

  private
    def markov_params
      params.require(:user).permit(:twitter_username)
    end
end
