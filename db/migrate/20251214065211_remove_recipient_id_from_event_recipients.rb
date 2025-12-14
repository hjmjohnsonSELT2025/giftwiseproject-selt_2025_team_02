class RemoveRecipientIdFromEventRecipients < ActiveRecord::Migration[8.1]
  def change
    remove_column :event_recipients, :recipient_id
  end
end
