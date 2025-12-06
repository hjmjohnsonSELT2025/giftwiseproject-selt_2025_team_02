class AddDetailsToRecipients < ActiveRecord::Migration[8.1]
  def change
    add_column :recipients, :occupation, :string
    add_column :recipients, :hobbies, :text
    add_column :recipients, :extra_info, :text
  end
end
