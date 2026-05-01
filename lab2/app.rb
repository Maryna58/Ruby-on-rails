require_relative 'recipe'
require_relative 'recipe_manager'

def clear_screen
  system('clear') || system('cls')
end

def prompt(text)
  print "#{text}: "
  gets.chomp
end

def handle_add(manager)
  puts "\nAdding a New Recipe"
  title        = prompt("Enter title")
  ingredients  = prompt("Enter ingredients (comma separated)").split(',').map(&:strip)
  steps        = prompt("Enter steps (comma separated)").split(',').map(&:strip)
  category     = prompt("Enter category")
  cooking_time = prompt("Enter cooking time")

  servings = 0
  loop do
    input = prompt("Enter servings (positive integer)").strip
    if input.match?(/^\d+$/) && input.to_i > 0
      servings = input.to_i
      break
    end
    puts "Servings must be a positive integer."
  end

  difficulty = ""
  loop do
    input = prompt("Enter difficulty (easy/medium/hard)").downcase.strip
    if ["easy", "medium", "hard"].include?(input)
      difficulty = input
      break
    end
    puts "Invalid difficulty. Must be easy, medium, or hard."
  end

  published_in = ""
  loop do
    input = prompt("Published? (y/n)").downcase.strip
    if ['y', 'n'].include?(input)
      published_in = input
      break
    end
    puts "Please enter 'y' or 'n'."
  end

  begin
    result = manager.add(
      title: title,
      ingredients: ingredients,
      steps: steps,
      category: category,
      cooking_time: cooking_time,
      servings: servings,
      difficulty: difficulty,
      published: (published_in == 'y')
    )
  
    if result
      puts "Successfully added '#{title}' to the collection!"
    end
  rescue ArgumentError => e
    puts "\nCould not add recipe: #{e.message}"
  end
end

def handle_edit(manager)
  id = prompt("Enter recipe id to edit").to_i
  recipe = manager.collection[id]

  unless recipe
    puts "Recipe id #{id} not found."
    return
  end

  puts "Fields: title, ingredients, steps, category, cooking_time, servings, difficulty, published"
  field = prompt("Which field to update?").downcase.to_sym

  if recipe.respond_to?(field)
    current_val = recipe.public_send(field)

    if current_val.is_a?(Array)
      puts "Current #{field}: #{current_val.join(', ')}"
      idx = prompt("Enter index to update (0, 1, 2...)").to_i
      new_item = prompt("Enter new value for #{field}[#{idx}]")
      current_val[idx] = new_item
      manager.edit_recipe(id, { field => current_val })
    else
      new_val = prompt("Enter new #{field} (Current: #{current_val})").strip
      
      if field == :published
        new_val = (new_val.downcase == 'y' || new_val.downcase == 'true')
      elsif field == :servings
        if new_val.match?(/^\d+$/) && new_val.to_i > 0
          new_val = new_val.to_i
        else
          puts "[ERROR] Servings must be a positive integer. Update cancelled."
          return
        end
      end

      begin
        manager.edit_recipe(id, { field => new_val })
        puts "Successfully updated #{field}"
      rescue ArgumentError => e
        puts "[ERROR] #{e.message}"
      end
    end
  else
    puts "Invalid field name"
  end
end

def handle_search(manager, type)
  results = case type
            when :title      then manager.find_by_title(prompt("Enter title or a piece of title"))
            when :category   then manager.filter_by_category(prompt("Enter category"))
            when :difficulty then manager.filter_by_difficulty(prompt("Enter difficulty"))
            end

  if results && results.any?
    puts "\nFound #{results.count}:"
    results.each { |id, r| puts "[#{id}] #{r.title} | Category: #{r.category} | Difficulty: #{r.difficulty}" }
  else
    puts "No recipes found."
  end
end

manager = RecipeManager.new

loop do
  print "Load from YAML - 1, JSON - 2, or start fresh - 3: "
  choice = gets.chomp

  case choice
  when "1"
    if File.exist?('recipes.yaml') && File.size('recipes.yaml') > 0
      manager.load_from_yaml('recipes.yaml')
    else
      puts "YAML file is missing or empty. Starting fresh."
    end
    break
  when "2"
    if File.exist?('recipes.json') && File.size('recipes.json') > 0
      manager.load_from_json('recipes.json')
    else
      puts "JSON file is missing or empty. Starting fresh."
    end
    break
  when "3"
    puts "Starting with an empty collection."
    break
  else
    puts "Invalid selection. Please enter 1, 2, or 3."
    puts "------------------------------------------"
  end
end

begin
  loop do
    puts "\nRecipe manager"
    puts "1 - list all recipes"
    puts "2 - add a recipe"
    puts "3 - edit a recipe"
    puts "4 - delete a recipe"
    puts "5 - filter by title"
    puts "6 - filter by category"
    puts "7 - filter by difficulty"
    puts "8 - Save to JSON"
    puts "9 - Save to YAML"
    puts "0 - exit!"

    choice = prompt("Select an option")
    puts "\n"

    case choice
    when "1"
      manager.list_recipes
    when "2"
      handle_add(manager)
    when "3"
      handle_edit(manager)
    when "4"
      id = prompt("Enter recipe id to delete").to_i
      manager.delete_recipe(id)
    when "5"
      handle_search(manager, :title)
    when "6"
      handle_search(manager, :category)
    when "7"
      handle_search(manager, :difficulty)
    when "8"
      manager.save_to_json('recipes.json')
    when "9"
      manager.save_to_yaml('recipes.yaml')
    when "0"
      puts "Exiting!"
      break
    else
      puts "Unavailable. Pick out of the available options"
    end
  end

ensure
  if manager.collection && manager.collection.any?
    manager.save_to_yaml('recipes.yaml')
    puts "\nAutosaved into recipes.yaml"
  else
    puts "\nCollection is empty. Skipping autosave"
  end
end