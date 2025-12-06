class AddAgeRangeToRecipients < ActiveRecord::Migration[8.1]
  def change
    add_column :recipients, :min_age, :integer
    add_column :recipients, :max_age, :integer
  end
end
