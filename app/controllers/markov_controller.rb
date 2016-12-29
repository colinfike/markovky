class MarkovController < ApplicationController
  def fetch_twitter_chain
    if !params[:twitter_username].blank?
      # TODO: Add check here for invalid username before creating the user
      user = User.find_or_create_by(twitter_username: params[:twitter_username])
      Markov.create_twitter_markov_chain(user) if user.markov_chain != {}
      sentence = Markov.generate_sentence(user)
      error = "Twitter user is private or invalid" if sentence == false
    else
      error = "Username Missing"
    end
    respond_to do |format|
      format.html
      format.json { render json: {:sentence => sentence, :error => error} }
    end
  end

  private
    def markov_params
      params.require(:user).permit(:twitter_username)
    end
end


# Plan
# 1)
