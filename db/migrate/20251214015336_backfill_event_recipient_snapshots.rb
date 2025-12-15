class BackfillEventRecipientSnapshots < ActiveRecord::Migration[8.1]
  def up
    say_with_time "Backfilling event_recipient snapshots" do
      EventRecipient.reset_column_information

      EventRecipient.all.each do |er|
        next unless er.recipient_id

        recipient = Recipient.find_by(id: er.recipient_id)
        next unless recipient

        er.update_columns(
          snapshot: recipient.attributes.except(
            "id",
            "user_id",
            "created_at",
            "updated_at"
          ),
          source_recipient_id: recipient.id
        )
      end
    end
  end

  def down
    # irreversible
  end
end
