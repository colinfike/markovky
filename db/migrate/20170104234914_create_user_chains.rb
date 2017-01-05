class CreateUserChains < ActiveRecord::Migration[5.0]
  def change
    create_table :user_chains do |t|
      t.integer :user_id
      t.text :markov_chain, :limit => 4294967295
      t.timestamps
    end
  end
end
