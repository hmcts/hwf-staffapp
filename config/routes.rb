Rails.application.routes.draw do

  get 'out_of_box/password' => 'out_of_box#password'
  get 'out_of_box/office' => 'out_of_box#office'
  get 'out_of_box/details' => 'out_of_box#details'

  get 'guide' => 'guide#index'

  get 'ping' => 'health_status#ping'
  get 'healthcheck' => 'health_status#healthcheck'

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

  %w[400 404 500 503].each do |error|
    get "static/#{error}" => "static##{error}"
  end

  devise_for :users, skip: :registrations, controllers: { invitations: 'users/invitations' }
  resources :users
  as :user do
    get 'users/:id/change_password' => 'devise/registrations#edit', as: 'edit_user_registration'
    patch 'users/:id/change_password' => 'users/registrations#update', as: 'user_registration'
  end
end
