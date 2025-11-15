class Recipient < ApplicationRecord
  belongs_to :user

  enum :gender, { male: 0, female: 1, other: 2 }

  validates :name, presence: true
  validates :age, presence: true, numericality: { only_integer: true, greater_than: 0, less_than: 120 }
  validates :gender, presence: true
  validates :relation, presence: true

  serialize :likes, coder: JSON
  serialize :dislikes, coder: JSON


  private

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
    "Hot Weather", "Math", "Cleaning", "Driving", "Flying","Seafood", 
    "Perfume", "Strong Smells", "Bright Lights", "Darkness"
  ]
end
