class Event < ApplicationRecord
  belongs_to :user
  has_many :event_recipients, dependent: :destroy
  has_many :recipients, through: :event_recipients
  validates :name, presence: true
  validates :event_date, presence: true
  validates :budget, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 1_000_000, allow_nil: true }

  validate :budget_not_scientific_notation
  validate :event_date_cannot_be_in_the_past
  validate :event_date_must_have_four_digit_year

  private

  def budget_not_scientific_notation
    budget_input = self.budget_before_type_cast
    return if budget_input.blank?

    if budget_input.to_s.match?(/[eE]/)
      errors.add(:budget, "must be a plain number (scientific notation not allowed)")
    end
  end

  def event_date_cannot_be_in_the_past
    return if event_date.blank?

    if event_date < Date.current
      errors.add(:event_date, "cannot be in the past")
    end
  end

  def event_date_must_have_four_digit_year
    return if event_date.blank?

    year = event_date.year
    unless (1000..9999).cover?(year)
      errors.add(:event_date, "year must have exactly four digits")
    end
  end
end
