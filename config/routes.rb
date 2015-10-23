Rails.application.routes.draw do

  get '/applications/new' => 'applications/build#create'
  resources :applications do
    resources :build, controller: 'applications/build'

    get 'benefit_override/paper_evidence', to: 'benefit_overrides#paper_evidence'
    post 'benefit_override/paper_evidence_save', to: 'benefit_overrides#paper_evidence_save'

    get 'personal_information', to: 'applications/process#personal_information', as: :personal_information
    put 'personal_information', to: 'applications/process#personal_information_save', as: :personal_information_save
  end

  get 'evidence/:id', to: 'evidence#show', as: :evidence_show
  get 'evidence/:id/accuracy', to: 'evidence#accuracy', as: :evidence_accuracy
  post 'evidence/:id/accuracy_save', to: 'evidence#accuracy_save', as: :evidence_accuracy_save
  get 'evidence/:id/income', to: 'evidence#income', as: :evidence_income
  post 'evidence/:id/income_save', to: 'evidence#income_save', as: :evidence_income_save
  get 'evidence/:id/result', to: 'evidence#result', as: :evidence_result
  get 'evidence/:id/summary', to: 'evidence#summary', as: :evidence_summary
  post 'evidence/:id/summary', to: 'evidence#summary_save', as: :evidence_summary_save
  get 'evidence/:id/confirmation', to: 'evidence#confirmation', as: :evidence_confirmation

  resources :evidence_checks, only: :show

  resources :payments, only: :show do
    member do
      get :accuracy
      post :accuracy_save
      get :summary
      post :summary_save
      get :confirmation
    end
  end

  get 'guide' => 'guide#index'
  get 'guide/process_application' => 'guide#process_application'
  get 'guide/evidence_checks' => 'guide#evidence_checks'
  get 'guide/part_payments' => 'guide#part_payments'
  get 'guide/appeals' => 'guide#appeals'
  get 'guide/suspected_fraud' => 'guide#suspected_fraud'

  get 'ping' => 'health_status#ping'
  get 'healthcheck' => 'health_status#healthcheck'
  get 'raise_exception' => 'health_status#raise_exception'

  get 'feedback' => 'feedback#new'
  get 'feedback/display' => 'feedback#index'

  post 'feedback/create' => 'feedback#create'

  get 'calculator/income' => 'calculator#income'
  post 'calculator/record_search' => 'calculator#record_search'

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
