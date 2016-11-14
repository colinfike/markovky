class CreateUsers < ActiveRecord::Migration[5.0]
  def change
    create_table :users do |t|

      t.string :twitter_username
      t.string :latest_tweet_seen
      t.text :markov_chain, :limit => 4294967295
      t.timestamps
    end
  end
end
