class AddExtraInfoToEvents < ActiveRecord::Migration[8.1]
  def change
    add_column :events, :extra_info, :text
  end
end
