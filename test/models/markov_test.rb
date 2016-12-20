require 'test_helper'

class MarkovTest < ActiveSupport::TestCase
  test "valid twitter user generates a dictionary" do
    user = User.create(twitter_username: "colinfike")
    Markov.create_twitter_markov_chain(user)
    assert user.markov_chain
  end

  test "bearer token as still valid" do
    response = RestClient.get("https://api.twitter.com/1.1/statuses/user_timeline.json?screen_name=colinfike", {"Authorization" => "Bearer #{TWITTER_BEARER_TOKEN}" })
    assert response
  end

  test "post processing" do
    temp_markov = {}
    temp_markov = Markov.process_post(temp_markov, "@colinfike Hey!! \n funny stuff http://tester.com/whop")
    assert temp_markov == {"["=>{"Hey"=>1}, "Hey"=>{"funny"=>1}, "funny"=>{"stuff"=>1}, "stuff"=>{"]"=>1}}
  end

  test "sentence generation" do
    user = User.create(twitter_username: 'colinfike', markov_chain: {"["=>{"Hey"=>1}, "Hey"=>{"funny"=>1}, "funny"=>{"stuff"=>1}, "stuff"=>{"]"=>1}})
    generated_sentence = Markov.generate_sentence(user)
    assert generated_sentence == "Hey funny stuff."
  end
end
