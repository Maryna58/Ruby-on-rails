require 'json'
require 'yaml'
require 'date'

class RecipeManager
  attr_accessor :collection

  def initialize
    @collection = {}
  end

  def each(&block)
    @collection.each_value(&block)
  end

  def add(recipe)
    return nil unless recipe.is_a?(Recipe)

    id = (@collection.keys.max || 0) + 1
    @collection[id] = recipe
    id
  end

  def edit_recipe(id, new_info)
    recipe = @collection[id]
    if recipe
      new_info.each do |key, value|
        setter = "#{key}="
        recipe.public_send(setter, value) if recipe.respond_to?(setter)
      end
    else
      puts "Recipe with ID #{id} not found"
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
        puts "[#{id}] #{r}"
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

  def load_from_json(filename)
    return unless File.exist?(filename) && !File.read(filename).strip.empty?
    data = JSON.parse(File.read(filename), symbolize_names: true)
    @collection = {}
    return unless data.is_a?(Hash)

    data.each do |id, recipe_hash|
      @collection[id.to_s.to_i] = Recipe.from_h(recipe_hash)
    end
    puts "Loaded from #{filename}"
  rescue => e
    puts "Error loading JSON: #{e.message}"
    @collection = {}
  end

  def load_from_yaml(filename)
    return unless File.exist?(filename)
    data = YAML.load_file(filename)
    @collection = {}
    return if data.nil? || !data.is_a?(Hash)

    data.each do |id, recipe_hash|
      @collection[id.to_s.to_i] = Recipe.from_h(recipe_hash)
    end
    puts "Loaded #{data.keys.size} recipes from #{filename}"
  rescue => e
    puts "Error loading YAML: #{e.message}"
    @collection = {}
  end

  def save_to_json(filename)
    hash_info = @collection.transform_values(&:to_h)
    File.write(filename, JSON.pretty_generate(hash_info))
    puts "Saved in #{filename}"
  end

  def save_to_yaml(filename)
    hash_info = @collection.transform_values(&:to_h)
    File.write(filename, hash_info.to_yaml)
    puts "Saved in #{filename}"
  end
end