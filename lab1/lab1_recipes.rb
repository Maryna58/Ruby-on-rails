# Варіант 3 — Менеджер рецептів

require 'json'
require 'yaml'

DIFFICULTIES = ['easy', 'medium', 'hard']

def add_recipe(recipes, title, ingredients, steps, category, cooking_time, servings, difficulty, created_at, published)
  id = recipes.keys.max.to_i + 1

  unless DIFFICULTIES.include?(difficulty)
    puts "Invalid difficulty, can't add the recipe"
  else
    recipes[id] = {
      title: title,
      ingredients: ingredients,
      steps: steps,
      category: category,
      cooking_time: cooking_time,
      servings: servings,
      difficulty: difficulty,
      created_at: created_at,
      published: published
    }
  end
  recipes
end

def edit_recipe(recipes, id, new_data)
  if recipes[id]
    recipes[id].merge!(new_data)
  else
    puts "Recipe with ID #{id} not found"
  end
  recipes
end

def delete_recipe(recipes, id)
  if recipes[id]
    recipes.delete(id)
  else
    puts "Recipe with ID #{id} not found"
  end
  recipes
end

def list_recipes(recipes)
  recipes.each do |id, r|
    puts "[#{id}] #{r[:title]} | #{r[:category]} | #{r[:cooking_time]} хв | Складність: #{r[:difficulty]} | #{r[:published] == "true" ? "Опубліковано" : "Не опубліковано"}"
  end
end

def find_by_title(recipes, part_title)
  recipes.select { |id, r| r[:title].downcase.include?(part_title.downcase) }
end

def filter_by_category(recipes, category)
  recipes.select { |id, r| r[:category].downcase == category.downcase }
end

def filter_by_difficulty(recipes, difficulty)
  recipes.select { |id, r| r[:difficulty].downcase == difficulty.downcase }
end


def save_to_json(recipes, filename)
  File.write(filename, JSON.pretty_generate(recipes))
  puts "Saved in #{filename}"
rescue => e
  puts "Error during saving: #{e.message}"
end

def load_from_json(filename)
  content = File.read(filename)
  return {} if content.strip.empty?

  data = JSON.parse(content)

  data.transform_keys(&:to_i).transform_values do |v|
    v.transform_keys(&:to_sym)
  end
rescue Errno::ENOENT
  puts "File #{filename} not found"
  {}
end

def save_to_yaml(recipes, filename)
  File.write(filename, recipes.to_yaml)
  puts "Saved in #{filename}"
rescue => e
  puts "Error during saving: #{e.message}"
end

def load_from_yaml(filename)
  YAML.load_file(filename) || {}
rescue Errno::ENOENT
  puts "File #{filename} not found"
  {}
end



recipes = {
  1 => {
    title: "Борщ",
    ingredients: ["буряк", "капуста", "морква"],
    steps: ["нарізати овочі", "зварити бульйон", "додати овочі"],
    category: "Супи",
    cooking_time: 60,
    servings: 4,
    difficulty: "easy",  # easy/medium/hard
    created_at: "2024-02-15",
    published: "false"
  }
}

puts "\n--- список рецептів ---"
list_recipes(recipes)

puts "\n--- додавання нового рецепта ---"
add_recipe(recipes, "Вареники", ["борошно", "картопля", "цибуля"], ["замісити тісто", "приготувати начинку", "зліпити"], "Основні страви", 90, 6, "easy", "2024-02-20", "true")
list_recipes(recipes)

puts "\n--- пошук за частиною'бор' ---"
results = find_by_title(recipes, "бор")
list_recipes(results)

puts "\n--- фільтр за складністю 'easy'"
easy_recipes = filter_by_difficulty(recipes, "easy")
list_recipes(easy_recipes)

puts "\n--- редагування ---"
edit_recipe(recipes, 2, { cooking_time: 75, published: "false" })
list_recipes(recipes)

puts "\n--- видалення ---"
delete_recipe(recipes, 1)
list_recipes(recipes)

puts "\n--- збереження та завантаження ---"

save_to_json(recipes, "test_recipes.json")
loaded_json = load_from_json("test_recipes.json")
puts "Завантажено рецепт #{loaded_json[2][:title]}"

save_to_yaml(recipes, "test_recipes.yaml")
loaded_yaml = load_from_yaml("test_recipes.yaml")
puts "Завантажено рецепт створений #{loaded_yaml[2][:created_at]}"