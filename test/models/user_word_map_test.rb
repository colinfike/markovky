require 'test_helper'

class UserWordMapTest < ActiveSupport::TestCase
  test "user_word_map can't save without word_map or user_id" do
    user_word_map = UserWordMap.new
    assert_not user_word_map.save
  end
  # TODO: Move other relevant tests here after refactor
end
