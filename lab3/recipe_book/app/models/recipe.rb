class Recipe < ApplicationRecord
  belongs_to :category

  enum :difficulty, { easy: 0, medium: 1, hard: 2 }

  validates :title, :cooking_time, :servings, presence: true
  validates :servings, numericality: { greater_than: 0 }
end
