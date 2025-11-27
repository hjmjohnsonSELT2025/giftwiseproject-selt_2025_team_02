class Event < ApplicationRecord
  belongs_to :user
  has_many :event_recipients, dependent: :destroy
  has_many :recipients, through: :event_recipients
  validates :name, presence: true
  validates :event_date, presence: true
  validates :budget, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 1_000_000, allow_nil: true }

  validate :budget_not_scientific_notation

  private

  def budget_not_scientific_notation
    budget_input = self.budget_before_type_cast
    return if budget_input.blank?

    if budget_input.to_s.match?(/[eE]/)
      errors.add(:budget, "must be a plain number (scientific notation not allowed)")
    end
  end
end
