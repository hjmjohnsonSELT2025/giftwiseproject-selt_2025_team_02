class GiftList < ApplicationRecord
  has_many :gifts, dependent: :destroy
  belongs_to :recipient
  has_one :user, through: :recipient
end
