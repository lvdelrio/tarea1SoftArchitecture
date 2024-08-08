Rails.application.routes.draw do
  get 'top_selling_books/index'
  get 'top_rated_books/index'
  get 'authors/index'
  get "up" => "rails/health#show", as: :rails_health_check

  root 'authors#index'
  get 'authors', to: 'authors#index'
  get 'top_rated_books', to: 'top_rated_books#index'
  get 'top_selling_books', to: 'top_selling_books#index'
end
