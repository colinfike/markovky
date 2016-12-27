require 'test_helper'

class HomeControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get root_url
    assert_response :success
  end

  test "should create user and return sentence" do
    post '/markov/fetch_twitter_chain.json', params: {:twitter_username => 'colinfike'}, xhr: true
    assert_equal JSON.parse(@response.body)['sentence'], 'Hey funny stuff.'
    assert_nil JSON.parse(@response.body)['error']
    assert_equal @response.content_type, 'application/json'
  end
end
