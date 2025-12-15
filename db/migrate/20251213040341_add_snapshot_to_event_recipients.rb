class AddSnapshotToEventRecipients < ActiveRecord::Migration[8.1]
  def change
    add_column :event_recipients, :snapshot, :jsonb, null: false, default: {}
    add_column :event_recipients, :source_recipient_id, :integer
  end
end
