class UserChain < ApplicationRecord
  serialize :markov_chain, Hash
  validates :markov_chain, presence: true
  validates :user_id, presence: true
  belongs_to :user
end
