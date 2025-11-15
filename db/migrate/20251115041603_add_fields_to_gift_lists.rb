class AddFieldsToGiftLists < ActiveRecord::Migration[8.1]
  def change
    add_reference :gift_lists, :recipient, null: false, foreign_key: true
  end
end
