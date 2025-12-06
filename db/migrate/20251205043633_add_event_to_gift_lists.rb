class AddEventToGiftLists < ActiveRecord::Migration[8.1]
  def change
    add_reference :gift_lists, :event, null: true, foreign_key: true
  end
end
