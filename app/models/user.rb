class User < ApplicationRecord
  serialize :markov_chain, Hash
end
