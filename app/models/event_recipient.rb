class EventRecipient < ApplicationRecord
  belongs_to :event
  belongs_to :recipient
  has_one :event_recipient_budget, dependent: :destroy

  validates :event_id, uniqueness: { scope: :recipient_id }
end
