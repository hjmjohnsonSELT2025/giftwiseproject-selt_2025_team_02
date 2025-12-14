class Recipient < ApplicationRecord
  belongs_to :user
  has_many :gift_lists, dependent: :destroy
  has_many :gifts, through: :gift_lists
  has_many :event_recipients, dependent: :destroy
  has_many :events, through: :event_recipients
  enum :gender, { male: 0, female: 1, other: 2 }

  AGE_RANGES = {
    "0-4 years"   => [ 0, 4 ],
    "5-9 years"   => [ 5, 9 ],
    "10-14 years" => [ 10, 14 ],
    "15-17 years" => [ 15, 17 ],
    "18-24 years" => [ 18, 24 ],
    "25-34 years" => [ 25, 34 ],
    "35-44 years" => [ 35, 44 ],
    "45-54 years" => [ 45, 54 ],
    "55-64 years" => [ 55, 64 ],
    "65-74 years" => [ 65, 74 ],
    "75-84 years" => [ 75, 84 ],
    "85-94 years" => [ 85, 94 ],
    "95+ years"   => [ 95, 120 ]  # or [95, nil] if you want open-ended
  }.freeze

  attr_writer :age_range

  def age_range
    @age_range || AGE_RANGES.key([ min_age, max_age ])
  end

  before_validation :apply_age_range
  before_validation :calculate_age, if: -> { birthday.present? || age.present? }


  validates :name, presence: true
  validates :gender, presence: true
  validates :relation, presence: true
  validates :age, :min_age, :max_age, numericality: { only_integer: true, greater_than: -1, less_than: 120 }, allow_nil: true

  validates :occupation, length: { maximum: 255 }, allow_blank: true
  validates :hobbies, length: { maximum: 2000 }, allow_blank: true
  validates :extra_info, length: { maximum: 4000 }, allow_blank: true

  validate :birthday_or_age_present
  validate :correct_age_range
  after_create :create_default_list

  serialize :likes, coder: JSON
  serialize :dislikes, coder: JSON

  def general_list
    gift_lists.find_by(name: "General ideas")
  end

  def has_birthday_event?
    events.where("name LIKE ?", "%birthday%").any?
  end

  def snapshot_attributes
    attributes.except(
      "id",
      "user_id",
      "created_at",
      "updated_at"
    )
  end

  private

  def birthday_or_age_present
    if birthday.blank? && age.blank? && min_age.blank? && max_age.blank?
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
      errors.add(:recipient, "Minimum age cannot be greater than maximum")
    end
  end

  def apply_age_range
    return if @age_range.blank?
    return if birthday.present?

    range = AGE_RANGES[@age_range]
    return if range.nil?

    self.min_age, self.max_age = range
    self.age = nil
    self.birthday = nil
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
    self.min_age = nil
    self.max_age = nil
  end

  def clean_arrays
    self.likes = likes.reject(&:empty?) if likes.present?
    self.dislikes = dislikes.reject(&:empty?) if dislikes.present?
  end

  def create_default_list
    gift_lists.create!(name: "General gift ideas for " + self.name)
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
