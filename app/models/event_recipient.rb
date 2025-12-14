class EventRecipient < ApplicationRecord
  belongs_to :event
  has_one :event_recipient_budget, dependent: :destroy

  validates :event_id, uniqueness: { scope: :source_recipient_id }

  def recipient_view
    RecipientProxy.new(snapshot)
  end
  def sync_back!(user)
    raise "No source recipient" unless source_recipient_id

    recipient = Recipient.find(source_recipient_id)
    raise "Not authorized" unless recipient.user_id == user.id

    recipient.update!(snapshot)
  end

  def source_gift_list
    return nil unless source_recipient_id

    GiftList.find_by(
      recipient_id: source_recipient_id,
      event_id: event_id
    )
  end
end
