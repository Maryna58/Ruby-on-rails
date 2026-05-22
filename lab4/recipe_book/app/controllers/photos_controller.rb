class PhotosController < ApplicationController
  before_action :set_photo, only: %i[edit update destroy]

  def create
    @photo = Photo.new(photo_params)
    if @photo.save
      redirect_to recipe_path(@photo.recipe_id), notice: "Фото успішно додано."
    else
      redirect_to recipe_path(@photo.recipe_id), alert: "Помилка при додаванні фото."
    end
  end

  def edit
    # Сторінка редагування підпису або URL фотографії
  end

  def update
    if @photo.update(photo_params)
      redirect_to recipe_path(@photo.recipe_id), notice: "Фото оновлено."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    recipe_id = @photo.recipe_id
    @photo.destroy
    redirect_to recipe_path(recipe_id), notice: "Фото видалено."
  end

  private

  def set_photo
    @photo = Photo.find(params[:id])
  end

  def photo_params
    params.require(:photo).permit(:caption, :url, :recipe_id)
  end
end