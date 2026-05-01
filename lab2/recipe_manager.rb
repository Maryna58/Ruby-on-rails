require 'json'
require 'yaml'

class RecipeManager
  attr_accessor   :collection

  def initialize
    @collection = {}
  end

  def each(&block)
    @collection.each_value(&block)
  end

  def add(title:, ingredients: [], steps: [], category:, cooking_time:, servings:, difficulty:, created_at: Date.today.to_s, published: false)

    unless valid_recipe_data?(title, category, cooking_time, difficulty)
      return nil
    end

    id = (@collection.keys.max || 0) + 1
    @collection[id] = Recipe.new(
      id: id,
      title: title,
      ingredients: ingredients,
      steps: steps,
      category: category,
      cooking_time: cooking_time,
      servings: servings,
      difficulty: difficulty,
      created_at: created_at,
      published: published
    )
  end

  def valid_recipe_data?(*args)
    is_invalid = args.any? do |arg|
      if arg.is_a?(Array)
        arg.empty? || arg.all? { |item| item.to_s.strip.empty? }
      else
        arg.to_s.strip.empty?
      end
    end
    if is_invalid
      puts "Error: All fields must be filled out!"
      return false
    end
    true
  end

  def edit_recipe(id, new_info)
    recipe = @collection[id]
    if recipe
      new_info.each do |key, value|
        setter = "#{key}="
        recipe.public_send(setter, value) if recipe.respond_to?(setter)
      end
    else
      puts  "Recipe with ID #{id} not found"
    end
  end

  def delete_recipe(id)
    @collection.delete(id) || puts("Recipe with ID #{id} not found")
  end

  def list_recipes
    if @collection.empty?
      puts "No recipes found"
    else
      @collection.each do |id, r|
        puts "[#{id}] #{r.title} | #{r.category} | #{r.cooking_time} | #{r.servings} | #{r.difficulty} | #{r.published}"
      end
    end
  end

  def find_by_title(part_title)
      @collection.select { |_, r| r.title.downcase.include?(part_title.downcase) }
  end

  def filter_by_category(category)
      @collection.select { |_, r| r.category.downcase == category.downcase }
  end

  def filter_by_difficulty(difficulty)
      @collection.select { |_, r| r.difficulty.downcase == difficulty.downcase }
  end

  def save_to_json(filename)
      hash_info = @collection.transform_values(&:to_h)
      File.write(filename, JSON.pretty_generate(hash_info))
      puts "Saved in #{filename}"
  rescue => e
      puts "Error during saving: #{e.message}"
  end

  def load_from_yaml(filename)
    return unless File.exist?(filename)

    data = YAML.load_file(filename) 
    @collection = {}
    
    return if data.nil? || !data.is_a?(Hash)

    data.each do |id, recipe_hash|
      @collection[id.to_s.to_i] = Recipe.from_h(id, recipe_hash)
    end
    puts "Loaded #{data.keys.size} recipes from #{filename}"
  rescue => e
    puts "Error loading YAML: #{e.message}"
    @collection = {}
  end

  def save_to_yaml(filename)
    hash_info = @collection.transform_values(&:to_h)
    File.write(filename, hash_info.to_yaml)
    puts "Saved in #{filename}"
  rescue => e
    puts "Error during saving: #{e.message}"
  end

  def load_from_yaml(filename)
    return unless File.exist?(filename)
    
    data = YAML.unsafe_load_file(filename)
    @collection = {}
    
    return unless data.is_a?(Hash)

    data.each do |id, recipe_hash|
      actual_hash = recipe_hash.is_a?(Hash) ? recipe_hash : recipe_hash.to_h
      @collection[id.to_s.to_i] = Recipe.from_h(id, actual_hash)
    end
    puts "Loaded from #{filename}"
  rescue => e
    puts "Error loading YAML: #{e.message}"
    @collection = {}
  end

end