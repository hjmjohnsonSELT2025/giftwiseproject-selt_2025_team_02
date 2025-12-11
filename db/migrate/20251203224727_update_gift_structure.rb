class UpdateGiftStructure < ActiveRecord::Migration[8.1]
  def change
    # gift lists acts as a container
    add_column :gift_lists, :title, :string
    add_column :gift_lists, :archived, :boolean, default: false, null: false
  end
end
