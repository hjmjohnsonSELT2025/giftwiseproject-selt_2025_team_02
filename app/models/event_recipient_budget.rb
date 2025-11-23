class EventRecipientBudget < ApplicationRecord
  belongs_to :user
  belongs_to :event
  belongs_to :recipient
end
