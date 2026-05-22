class Photo < ApplicationRecord
  belongs_to :recipe

  validates :url, presence: true
  validates :caption, presence: true
end
