require 'test_helper'

class NewUserFlowTest < ActionDispatch::IntegrationTest
  # TODO: Consider updating/adding tests that can test the coffeescript that is fired
  # on the home#index page when the user submits their twitter username. This simulates
  # that workflow but does not ensure that the response is actually rendered properly in the
  # sentence-container div. TEST OUT CAPYBARA
  test 'can create a user and fetch markov' do
    get root_url
    assert_response :success

    post '/markov/fetch_twitter_chain', params: {twitter_username: 'colinfike'}, xhr: true
    assert_response :success
  end
end
