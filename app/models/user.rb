class User < ApplicationRecord
  serialize :markov_chain, Hash
  validates :twitter_username, presence: true, uniqueness: true
end
