class RemoveRecipientIdFromEventRecipients < ActiveRecord::Migration[8.1]
  def change
    remove_index :event_recipients,
                 name: "index_event_recipients_on_event_id_and_recipient_id"

    remove_foreign_key :event_recipients, :recipients rescue nil

    remove_column :event_recipients, :recipient_id
  end
end
