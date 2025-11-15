class Gift < ApplicationRecord
  validates :name, presence: true
  belongs_to :gift_list
  has_one :recipient, through: :gift_list
  has_one :user, through: :recipient
end

