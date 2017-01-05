require 'test_helper'

class HomeControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get root_url
    assert_response :success
  end

  test "should create user and return sentence" do
    post fetch_twitter_chain_markov_index_url, params: {:twitter_username => 'colinfike'}, xhr: true, as: :json
    assert JSON.parse(@response.body)['sentence']
    assert_nil JSON.parse(@response.body)['error']
    assert_equal @response.content_type, 'application/json'
  end

  test "should return error on user creation failure" do
    post fetch_twitter_chain_markov_index_url, params: {:twitter_username => ''}, xhr: true, as: :json
    assert_nil JSON.parse(@response.body)['sentence']
    assert_equal JSON.parse(@response.body)['error'], 'Twitter user is private or invalid'
    assert_equal @response.content_type, 'application/json'
  end

  test "should return error on invalid twitter name failure" do
    post fetch_twitter_chain_markov_index_url, params: {:twitter_username => users(:impossible_twitter_handle).twitter_username}, xhr: true, as: :json
    assert_not JSON.parse(@response.body)['sentence']
    assert_equal JSON.parse(@response.body)['error'], 'Twitter user is private or invalid'
    assert_equal @response.content_type, 'application/json'
  end
end
