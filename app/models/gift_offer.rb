class GiftOffer < ApplicationRecord
  belongs_to :gift

  validates :store_name, presence: true
  validates :price,
            presence: true,
            numericality: { greater_than_or_equal_to: 0 }

  validates :currency, presence: true

  validates :rating,
            numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 5 },
            allow_nil: true
end
