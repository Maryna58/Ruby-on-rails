Rails.application.routes.draw do
  resources :ingredients
  resources :categories

  resources :photos, only: [:create, :edit, :update, :destroy]

  resources :recipes do
    collection do
      get :published
      get :quick
    end

    member do
      patch :toggle_publish
    end
  end

  root "recipes#index"
end