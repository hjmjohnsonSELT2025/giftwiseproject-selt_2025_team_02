class Gift < ApplicationRecord
  validates :name, presence: true
  belongs_to :gift_list
  has_one :recipient, through: :gift_list
  has_one :user, through: :recipient

  has_many :gift_offers, dependent: :destroy

  enum :status, {
    idea: 0,
    planned: 1,
    ordered: 2,
    acquired: 3,
    wrapped: 4,
    given: 5
  }
end
