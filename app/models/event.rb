class Event < ApplicationRecord
  belongs_to :user
  has_many :event_recipients, dependent: :destroy
  has_many :recipients, through: :event_recipients
  validates :name, presence: true
  validates :event_date, presence: true
end
