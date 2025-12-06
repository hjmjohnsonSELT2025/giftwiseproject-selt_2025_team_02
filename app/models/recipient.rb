class Recipient < ApplicationRecord
  belongs_to :user
  has_many :gift_lists
  has_many :gifts, through: :gift_lists
  has_many :event_recipients, dependent: :destroy
  has_many :events, through: :event_recipients
  enum :gender, { male: 0, female: 1, other: 2 }

  validates :name, presence: true
  validates :gender, presence: true
  validates :relation, presence: true
  validates :age, :min_age, :max_age, numericality: { only_integer: true, greater_than: 0, less_than: 120 }, allow_nil: true

  validates :occupation, length: { maximum: 255 }, allow_blank: true
  validates :hobbies, length: { maximum: 2000 }, allow_blank: true
  validates :extra_info, length: { maximum: 4000 }, allow_blank: true
  
  validate :birthday_or_age_present
  validate :correct_age_range

  serialize :likes, coder: JSON
  serialize :dislikes, coder: JSON

  before_save :calculate_age, if: -> { birthday.present? }
  before_update :calculate_age, if: -> { birthday.present? || age.present? }

  private

  def birthday_or_age_present
    if birthday.blank? && age.blank? && min_age.blank?
      errors.add(:recipient, "Please provide either a birthday or an age.")
    end
  end

  def correct_age_range
    return if min_age.blank? && max_age.blank?
    if max_age.present? && !(min_age.present?)
      errors.add(:recipient, "Set min age first")
      return
    end

    if max_age.present? && min_age > max_age
      errors.add(:recipient, "Minimum age can not be greater than maximum")
    end
  end


  def calculate_age
    # allows for changing from pre-set age to now min/max age
    if birthday.blank? && age.present?
      self.min_age = age
      self.max_age = nil
      self.age = nil
      return
    end

    today = Date.current
    years = today.year - birthday.year

    years -= 1 if birthday.change(year: today.year) > today
    self.age = years
  end

  def clean_arrays
    self.likes = likes.reject(&:empty?) if likes.present?
    self.dislikes = dislikes.reject(&:empty?) if dislikes.present?
  end


  LIKES_OPTIONS = [
    "Reading", "Sports", "Music", "Cooking", "Traveling", "Art", "Technology",
    "Gardening", "Photography", "Dancing", "Movies", "Video Games", "Pets",
    "Fashion", "Fitness", "Writing", "Puzzles", "Board Games", "Hiking",
    "Swimming", "Cycling", "Yoga", "Meditation", "Volunteering", "Theater",
    "Concerts", "Camping", "Fishing", "Golf", "Tennis", "Basketball", "Soccer"
  ]

  DISLIKES_OPTIONS = [
    "Spicy Food", "Loud Noises", "Crowds", "Heights", "Insects", "Cold Weather",
    "Hot Weather", "Math", "Cleaning", "Driving", "Flying", "Seafood",
    "Perfume", "Strong Smells", "Bright Lights", "Darkness"
  ]
end
