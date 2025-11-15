class GiftList < ApplicationRecord
  has_many :gifts
  belongs_to :recipient
  has_one :user, through: :recipient
end

