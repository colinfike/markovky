class MarkovController < ApplicationController
  def index
  end

  def fetch_twitter_chain
    user = User.find_or_create_by(twitter_username: params[:username])
    create_twitter_markov_chain(user)
    @sentence = generate_sentence(user)
  end
end
