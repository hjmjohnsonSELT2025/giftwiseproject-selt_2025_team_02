class CreateGiftLists < ActiveRecord::Migration[8.1]
  def change
    create_table :gift_lists do |t|
      t.string :name

      t.timestamps
    end
  end
end
