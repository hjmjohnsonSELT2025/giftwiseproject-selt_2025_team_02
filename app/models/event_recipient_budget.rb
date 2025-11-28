class EventRecipientBudget < ApplicationRecord
  belongs_to :event_recipient
  has_one :event, through: :event_recipient
  has_one :recipient, through: :event_recipient

  attr_accessor :event_id, :recipient_id
  
  validates :budget, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 100000000 }
  validates :spent, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 100000000 }
end
