class CreateMarkovs < ActiveRecord::Migration[5.0]
  def change
    create_table :markovs do |t|

      t.timestamps
    end
  end
end
