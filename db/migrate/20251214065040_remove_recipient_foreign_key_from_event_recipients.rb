class RemoveRecipientForeignKeyFromEventRecipients < ActiveRecord::Migration[8.1]
  def change
    remove_foreign_key :event_recipients, :recipients
  end
end

