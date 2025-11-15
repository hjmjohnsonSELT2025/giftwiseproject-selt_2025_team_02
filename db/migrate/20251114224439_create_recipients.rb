class CreateRecipients < ActiveRecord::Migration[8.1]
  def change
    create_table :recipients do |t|
      t.string :name
      t.integer :age
      t.integer :gender
      t.string :relation
      t.text :likes
      t.text :dislikes
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end
