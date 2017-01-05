class MarkovController < ApplicationController
  def fetch_twitter_chain
    # Whole section with error handling is a mess but it prevents some unenecessary saves of the object
    # if I did it a bit cleaner. I cut down on code duplication but I don't think that may be a good thing in this case.
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

  private
    def markov_params
      params.require(:user).permit(:twitter_username)
    end
end
