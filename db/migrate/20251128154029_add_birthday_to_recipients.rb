class AddBirthdayToRecipients < ActiveRecord::Migration[8.1]
  def change
    add_column :recipients, :birthday, :date
  end
end
