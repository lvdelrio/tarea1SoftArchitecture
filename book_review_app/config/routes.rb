Rails.application.routes.draw do
  resources :books
  resources :authors
  resources :reviews
  resources :yearly_sales

  get 'top_selling_books', to: 'top_selling_books#index'
  get 'top_rated_books', to: 'top_rated_books#index'

  get "up" => "rails/health#show", as: :rails_health_check

  root 'authors#index'

end
