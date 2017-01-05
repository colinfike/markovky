class CreateUserWordMaps < ActiveRecord::Migration[5.0]
  def change
    create_table :user_word_maps do |t|
      t.integer :user_id
      t.text :word_map, :limit => 4294967295
      t.timestamps
    end
  end
end
