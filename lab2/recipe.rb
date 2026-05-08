require 'date'

DIFFICULTIES = ['easy', 'medium', 'hard']

class Recipe
  attr_reader :servings, :difficulty
  attr_accessor :title, :ingredients, :steps, :category, :cooking_time, :created_at, :published

  def title=(val)
    raise ArgumentError, "Title cannot be empty!" if val.to_s.strip.empty?
    @title = val
  end

  def category=(val)
    raise ArgumentError, "Category cannot be empty!" if val.to_s.strip.empty?
    @category = val
  end

  def cooking_time=(val)
    raise ArgumentError, "Cooking time cannot be empty!" if val.to_s.strip.empty?
    @cooking_time = val
  end

  def difficulty=(level)
    unless DIFFICULTIES.include?(level.to_s.downcase.strip)
      raise ArgumentError, "Невірна складність. Доступні варіанти: #{DIFFICULTIES.join(', ')}"
    end
    @difficulty = level.to_s.downcase.strip
  end

  def servings=(num)
    val = num.to_i
    if val <= 0
      raise ArgumentError, "Кількість порцій має бути додатнім числом."
    end
    @servings = val
  end

  def initialize(title:, ingredients: [], steps: [], category:, cooking_time:, servings:, difficulty:, created_at: Date.today.to_s, published: false)
    self.title = title
    @ingredients = ingredients
    @steps = steps
    self.category = category
    self.cooking_time = cooking_time
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

  def self.from_h(hash)
    new(
      title: hash[:title],
      ingredients: hash[:ingredients] || [],
      steps: hash[:steps] || [],
      category: hash[:category],
      cooking_time: hash[:cooking_time],
      servings: hash[:servings],
      difficulty: hash[:difficulty],
      created_at: hash[:created_at] || Date.today.to_s,
      published: hash[:published] || false
    )
  end

  def to_s
    "#{@title} | #{@category} | #{@cooking_time} | #{@servings} | #{@difficulty} | #{@published}"
  end
end