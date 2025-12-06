class GiftList < ApplicationRecord
  has_many :gifts
  belongs_to :recipient
  belongs_to :event, optional: true
  has_one :user, through: :recipient
  validates :name, presence: true
  # archiving functionality to hide previous lists for old events
  scope :active, -> { where(archived: false) }
end
