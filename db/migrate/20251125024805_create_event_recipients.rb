class CreateEventRecipients < ActiveRecord::Migration[8.1]
  def change
    create_table :event_recipients do |t|
      t.references :event, null: false, foreign_key: true
      t.references :recipient, null: false, foreign_key: true

      t.timestamps
    end
    add_index :event_recipients, [ :event_id, :recipient_id ], unique: true # don't add same recipient twice
  end
end
