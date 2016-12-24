require 'test_helper'

class MarkovTest < ActiveSupport::TestCase
  test "valid twitter user generates a dictionary" do
    user = users(:colin)
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
    assert_equal temp_markov, {"["=>{"Hey"=>1}, "Hey"=>{"funny"=>1}, "funny"=>{"stuff"=>1}, "stuff"=>{"]"=>1}}
  end

  test "sentence generation" do
    user = users(:colin_with_markov)
    generated_sentence = Markov.generate_sentence(user)
    assert_equal generated_sentence, "Hey funny stuff."
  end

  test "sentence generation graceful failure" do
    user = users(:colin)
    generated_sentence = Markov.generate_sentence(user)
    assert_not generated_sentence
  end

  test "test invalid twitter name error handling" do
    user = users(:impossible_twitter_handle)
    assert_nothing_raised{ Markov.create_twitter_markov_chain(user) }
  end
end
