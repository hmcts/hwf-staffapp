Rails.application.routes.draw do
  get 'guide' => 'guide#index'

  get 'ping' => 'health_status#ping'

  get 'feedback' => 'feedback#new'
  get 'feedback/display' => 'feedback#index'

  post 'feedback/create' => 'feedback#create'

  get 'calculator/income' => 'calculator#income'
  post 'calculator/record_search' => 'calculator#record_search'

  get 'dwp_checks' => 'dwp_checks#new', as: 'new_dwp_checks'
  post 'dwp_checks/lookup'
  get 'dwp_checks/:unique_number' => 'dwp_checks#show', as: 'dwp_checks'

  resources :offices

  root to: 'home#index'

  get 'home/index'

  devise_for :users, controllers: { invitations: 'users/invitations' }
  resources :users
end
