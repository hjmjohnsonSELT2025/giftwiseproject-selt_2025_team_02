class AddUserToGifts < ActiveRecord::Migration[8.1]
  def change
    add_reference :gifts, :user, null: true, foreign_key: true
  end
end
