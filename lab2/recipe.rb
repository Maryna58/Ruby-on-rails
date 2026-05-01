require 'date'

DIFFICULTIES = ['easy', 'medium', 'hard']

class Recipe
  attr_reader :id, :servings, :difficulty
  attr_accessor :title, :ingredients, :steps, :category, :cooking_time, :created_at, :published

  def difficulty=(level)
    unless DIFFICULTIES.include?(level.to_s.downcase.strip)
      raise ArgumentError, "Невірна складність. Доступні варіанти: #{DIFFICULTIES.join(', ')}"
    end
    @difficulty = level.to_s.downcase.strip
  end

  def servings=(num)
    val = num.to_s.strip
    unless val.match?(/^\d+$/) && val.to_i > 0
      raise ArgumentError, "Кількість порцій має містити ТІЛЬКИ цифри."
    end
    @servings = val.to_i
  end

  def initialize(id:, title:, ingredients: [], steps: [], category:, cooking_time:, servings:, difficulty:, created_at: Date.today.to_s, published: false)
    @id = id
    @title = title
    @ingredients = ingredients
    @steps = steps
    @category = category
    @cooking_time = cooking_time
    self.servings = servings
    self.difficulty = difficulty
    @created_at = created_at
    @published = published
  end

  def to_h
    {
      title: @title,
      ingredients: @ingredients,
      steps: @steps,
      category: @category,
      cooking_time: @cooking_time,
      servings: @servings,
      difficulty: @difficulty,
      created_at: @created_at,
      published: @published
    }
  end

  def self.from_h(id, hash)
    new(
      id: id.to_i,
      title: hash[:title],
      ingredients: hash[:ingredients],
      steps: hash[:steps],
      category: hash[:category],
      cooking_time: hash[:cooking_time],
      servings: hash[:servings],
      difficulty: hash[:difficulty],
      created_at: hash[:created_at],
      published: hash[:published]
    )
  end
end