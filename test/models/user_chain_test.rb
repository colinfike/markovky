require 'test_helper'

class UserChainTest < ActiveSupport::TestCase
  test "user_chain can't save without markov_chain or user_id" do
    user_chain = UserChain.new
    assert_not user_chain.save
  end
  # TODO: Move other relevant tests here after refactor
end
