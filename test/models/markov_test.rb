require 'test_helper'

class MarkovTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end

  test "valid twitter user generates a dictionary" do
    user = User.create(twitter_username: "colinfike")
    Markov.create_twitter_markov_chain(user)
    assert user.markov_chain
  end
end
