class UserWordMap < ApplicationRecord
  serialize :word_map, Hash
  validates :word_map, presence: true
  validates :user_id, presence: true
  belongs_to :user
end
