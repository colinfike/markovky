class User < ApplicationRecord
  serialize :markov_chain, Hash
  validates :twitter_username, presence: true, uniqueness: true
  has_one :user_chain, dependent: :destroy
  has_one :user_word_map, dependent: :destroy
end
