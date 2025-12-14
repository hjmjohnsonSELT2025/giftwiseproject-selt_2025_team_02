class EventRecipient < ApplicationRecord
  belongs_to :event
  has_one :event_recipient_budget, dependent: :destroy

  validates :event_id, uniqueness: { scope: :source_recipient_id }


  def self.snapshot_from(recipient)
    recipient.attributes.except(
      "id",
      "user_id",
      "created_at",
      "updated_at"
    )
  end
  # def self.create_from_recipient!(event:, recipient:)
  #   create!(
  #     event: event,
  #     source_recipient_id: recipient.id,
  #     snapshot: EventRecipient.snapshot_from(recipient)
  #   )
  # end

  def recipient_view
    RecipientProxy.new(snapshot)
  end
  def sync_back!(user)
    raise "No source recipient" unless source_recipient_id

    recipient = Recipient.find(source_recipient_id)
    raise "Not authorized" unless recipient.user_id == user.id

    recipient.update!(snapshot)
  end

end
