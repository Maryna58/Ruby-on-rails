module RecipesHelper
  def difficulty_badge(recipe)
    return content_tag(:span, "Не вказано", class: "badge bg-secondary") if recipe.difficulty.blank?

    css_class = case recipe.difficulty
    when "easy"   then "badge bg-success"
    when "medium" then "badge bg-warning"
    when "hard"   then "badge bg-danger"
    else "badge bg-secondary"
    end

    content_tag(:span, recipe.difficulty, class: css_class)
  end
end
