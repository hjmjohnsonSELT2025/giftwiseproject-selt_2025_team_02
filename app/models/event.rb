class Event < ApplicationRecord
  belongs_to :user
  has_many :event_recipient_budgets, dependent: :destroy
  has_many :recipients, through: :event_recipient_budgets
end
