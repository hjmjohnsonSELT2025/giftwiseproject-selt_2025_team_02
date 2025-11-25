class EventRecipientBudget < ApplicationRecord
  belongs_to :user
  belongs_to :event
  belongs_to :recipient

  validates :total_budget, numericality: { greater_than_or_equal_to: 0, less_than: 100000000 }
  validates :spent_budget, numericality: { greater_than_or_equal_to: 0, less_than: :total_budget }
end