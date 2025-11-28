class EventRecipient < ApplicationRecord
  belongs_to :event
  belongs_to :recipient
  validates :event_id, uniqueness: { scope: :recipient_id }
end
