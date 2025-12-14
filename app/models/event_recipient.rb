class EventRecipient < ApplicationRecord
  belongs_to :event
  belongs_to :recipient
  has_one :event_recipient_budget, dependent: :destroy

  validates :event_id, uniqueness: { scope: :recipient_id }


  def [](key)
    snapshot[key.to_s]
  end

  def sync_back!(user)
    raise "No source recipient" unless source_recipient_id

    recipient = Recipient.find(source_recipient_id)
    raise "Not authorized" unless recipient.user_id == user.id

    recipient.update!(snapshot)
  end

end
