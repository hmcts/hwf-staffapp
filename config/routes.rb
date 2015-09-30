Rails.application.routes.draw do

  get '/applications/new' => 'applications/build#create'
  resources :applications do
    resources :build, controller: 'applications/build'
  end
  resources :spotchecks, only: :show

  get 'guide' => 'guide#index'

  get 'ping' => 'health_status#ping'
  get 'healthcheck' => 'health_status#healthcheck'
  get 'raise_exception' => 'health_status#raise_exception'

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

  get 'users/deleted' => 'users#deleted', as: 'deleted_users'
  patch 'users/:id/restore' => 'users#restore', as: 'restore_user'
  devise_for :users, skip: :registrations, controllers: { invitations: 'users/invitations' }
  resources :users
  as :user do
    get 'users/:id/change_password' => 'devise/registrations#edit', as: 'edit_user_registration'
    patch 'users/:id/change_password' => 'users/registrations#update', as: 'user_registration'
  end
end
