class Recipe < ApplicationRecord
  belongs_to :category
  has_many :photos, dependent: :destroy

  accepts_nested_attributes_for :photos, allow_destroy: true, reject_if: :all_blank

  enum :difficulty, { easy: 0, medium: 1, hard: 2 }

  validates :title, :cooking_time, :servings, presence: true
  validates :servings, numericality: { greater_than: 0 }

  # --- SCOPES ---
  #  Два scopes по published
  scope :published, -> { where(published: true) }
  scope :drafts, -> { where(published: false) }

  # Scope по еnum
  scope :easy_difficulty, -> { where(difficulty: :easy) }

  # Scope по числовому полю
  scope :quick, -> { where("cooking_time <= ?", 30) }

  # --- запити ---
  # всі неопубліковані, відсортовані за cooking_time
  def self.unpublished_sorted
    drafts.order(cooking_time: :asc)
  end

  # Три найшвидші рецепти
  def self.top_three_fastest
    order(cooking_time: :asc).limit(3)
  end

  # Пошук за словом у назві
  def self.search_by_title(query)
    where("title ILIKE ?", "%#{query}%") # ILIKE для нечутливості до регістру в PostgreSQL
  end
end