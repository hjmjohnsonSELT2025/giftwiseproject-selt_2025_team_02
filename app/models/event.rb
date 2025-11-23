class Event < ApplicationRecord
  belongs_to :use
  has_many :event_recipient_budgets, dependedent: :destroy
  has_many :recipients, through: :event_recipient_budgets
end
