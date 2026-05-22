class RecipesController < ApplicationController
  before_action :set_recipe, only: %i[show edit update destroy toggle_publish]

  def index
    @recipes = Recipe.includes(:category).all
  end

  def published
    @recipes = Recipe.published.includes(:category)
  end

  def quick
    @recipes = Recipe.quick.includes(:category)
    render :published
  end

  def show
    @photo = Photo.new
  end

  def new
    @recipe = Recipe.new
    @recipe.photos.build
  end

  def edit
    @recipe.photos.build if @recipe.photos.empty?
  end

  def create
    @recipe = Recipe.new(recipe_params)

    if @recipe.save
      redirect_to @recipe, notice: "Рецепт успішно створено."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @recipe.update(recipe_params)
      redirect_to @recipe, notice: "Рецепт успішно оновлено."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @recipe.destroy
    redirect_to recipes_path, notice: "Рецепт видалено."
  end

  def toggle_publish
    @recipe.update(published: !@recipe.published)
    redirect_to @recipe, notice: "Статус публікації змінено."
  end

  private

  def set_recipe
    @recipe = Recipe.find(params[:id])
  end

  def recipe_params
    params.require(:recipe).permit(
      :title, :ingredients, :steps, :cooking_time, :servings, :difficulty, :published, :category_id,
      photos_attributes: [:id, :url, :caption, :_destroy]
    )
  end
end