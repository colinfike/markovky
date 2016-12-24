require 'test_helper'

class NewUserFlowTest < ActionDispatch::IntegrationTest
  test 'can create a user and fetch markov' do
    get root_url
    assert_response :success

    post '/markov/fetch_twitter_chain', params: {twitter_username: 'colinfike'}
    assert_response :success
  end
end
