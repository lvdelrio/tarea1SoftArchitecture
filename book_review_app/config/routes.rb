Rails.application.routes.draw do
  resources :books, only: [:index]
  resources :authors
  resources :reviews
  resources :yearly_sales
  get 'top_selling_books/index'
  get 'top_rated_books/index'
  get 'authors/index'
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  root 'authors#index'
  get 'authors', to: 'authors#index'
  get 'top_rated_books', to: 'top_rated_books#index'
  get 'top_selling_books', to: 'top_selling_books#index'

end
