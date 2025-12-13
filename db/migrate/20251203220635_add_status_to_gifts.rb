class AddStatusToGifts < ActiveRecord::Migration[8.1]
  def change
    add_column :gifts, :status, :integer, default: 0
    add_index :gifts, :status
  end
end
