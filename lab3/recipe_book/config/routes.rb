Rails.application.routes.draw do
  resources :ingredients
  resources :categories

  resources :recipes do
    collection do
      get :published
    end

    member do
      patch :toggle_publish
    end
  end

  root "recipes#index"
end
