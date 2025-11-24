Rails.application.routes.draw do

  resource :notifications, only: [:edit, :update]
  resource :dwp_warnings, only: [:edit, :update]

  post 'api/submissions' => 'api/submissions#create'
  post 'api/calculate_percentage_fee' => 'api/fee_calculator#calculate_percentage_fee'
  get 'reports' => 'reports#index'
  get 'reports/public' => 'reports#public'
  get 'reports/finance_report' => 'reports#finance_report'
  get 'reports/finance_transactional_report' => 'reports#finance_transactional_report'
  get 'reports/graphs' => 'reports#graphs', as: :graphs_report
  put 'reports/finance_report' => 'reports#finance_report_generator'
  put 'reports/finance_transactional_report' => 'reports#finance_transactional_report_generator'
  get 'letter_templates' => 'reports#letters'
  get 'new_letter_templates' => 'reports#new_letters'

  namespace :report do
    get 'ccmcc_data' => 'ccmcc_data#show'
    put 'ccmcc_data' => 'ccmcc_data#data_export'
    get 'income_claims_data' => 'income_claims_data#show'
    put 'income_claims_data' => 'income_claims_data#data_export'
    get 'power_bi' => 'power_bi#show'
    put 'power_bi' => 'power_bi#data_export'
    get 'raw_data' => 'raw_data#show'
    put 'raw_data' => 'raw_data#data_export'
    get 'ocmc' => 'ocmc#show'
    put 'ocmc' => 'ocmc#data_export'
    get 'hmrc' => 'hmrc#show'
    put 'hmrc' => 'hmrc#data_export'
    get 'purge_audit' => 'purge_audit#show'
    put 'purge_audit' => 'purge_audit#data_export'
  end

  get '/applications/new' => 'applications/build#create'
  resources :applications, only: [] do

    collection do
      post 'create', to: 'applications/process#create', as: :create
    end

    get 'benefit_override/paper_evidence', to: 'benefit_overrides#paper_evidence'
    post 'benefit_override/paper_evidence_save', to: 'benefit_overrides#paper_evidence_save'

    get 'income_result', to: 'applications/process#income_result', as: :income_result
    get ':type/confirmation', to: 'applications/process/confirmation#index', as: :confirmation,
                              defaults: { type: 'paper' }
    put 'override', to: 'applications/process/override#update', as: :override

    get '/fee_status', to: 'applications/process/fee_status#index'
    post '/fee_status', to: 'applications/process/fee_status#create'
    get '/declaration', to: 'applications/process/declaration#index'
    post '/declaration', to: 'applications/process/declaration#create'
    get '/representative', to: 'applications/process/representative#index'
    post '/representative', to: 'applications/process/representative#create'
    resources :personal_informations, only: [:index, :create], module: 'applications/process'
    resources :partner_informations, only: [:index, :create], module: 'applications/process'
    resources :details, only: [:index, :create], module: 'applications/process'
    resources :savings_investments, only: [:index, :create], module: 'applications/process'
    resources :benefits, only: [:index, :create], module: 'applications/process'
    resources :dependents, only: [:index, :create], module: 'applications/process'
    resources :incomes, only: [:index, :create], module: 'applications/process'
    resources :income_kind_applicants, only: [:index, :create], module: 'applications/process'
    resources :income_kind_partners, only: [:index, :create], module: 'applications/process'
    get 'summary', to: 'applications/process/summary#index'
    post 'summary', to: 'applications/process/summary#create'

    get 'approve', to: 'applications/process/details#approve'
    put 'approve', to: 'applications/process/details#approve_save'
  end

  resources :online_applications, only: [:edit, :update, :show] do
    member do
      post :complete
      get 'approve', to: 'online_applications#approve'
      put 'approve', to: 'online_applications#approve_save'
      get 'benefits', to: 'online_application_benefits#edit'
      put 'benefits', to: 'online_application_benefits#update'
    end
  end

  resources :evidence, only: :show do
    member do
      get :accuracy
      post :accuracy_save
      get :income
      post :income_save
      get :result
      get :summary
      post :summary_save
      get :confirmation
      get :return_letter
    end
  end

  namespace :evidence do
    resources :accuracy_failed_reason, only: [:show, :update]
    resources :accuracy_incorrect_reason, only: [:show, :update]
  end

  resources :evidence_checks, only: [:index, :show] do
    resources :hmrc, module: 'evidence'
    resource :hmrc_skip, module: 'evidence', only: :update

    scope module: 'evidence' do
      get ':id/show', to: 'hmrc_summary#show', as: :hmrc_summary
      post ':id/complete', to: 'hmrc_summary#complete', as: :hmrc_complete
    end
  end

  resources :part_payments, only: [:index, :show] do
    member do
      get :accuracy
      post :accuracy_save
      get :summary
      post :summary_save
      get :confirmation
      get :return_letter
      post :return_application
    end
  end

  resources :processed_applications, only: [:index, :show, :update]
  resources :deleted_applications, only: [:index, :show]
  resources :dwp_failed_applications, only: [:index]

  get 'guide' => 'guide#index'
  get 'guide/process_application' => 'guide#process_application'
  get 'guide/evidence_checks' => 'guide#evidence_checks'
  get 'guide/part_payments' => 'guide#part_payments'
  get 'guide/appeals' => 'guide#appeals'
  get 'guide/suspected_fraud' => 'guide#suspected_fraud'

  #  get 'ping' => 'health_status#ping'
  #  get 'healthcheck' => 'health_status#healthcheck'
  get 'raise_exception' => 'health_status#raise_exception'

  get '/health' => 'health_status#show', defaults: { format: 'json' }
  get '/health/readiness' => 'health_status#show', defaults: { format: 'json' }
  get '/health/liveness' => 'health_status#show', defaults: { format: 'json' }

  get 'feedback' => 'feedback#new'
  get 'feedback/display' => 'feedback#index'

  post 'feedback/create' => 'feedback#create'

  resources :offices do
    resources :business_entities do
      member do
        get 'deactivate'
        post 'confirm_deactivate'
      end
    end
  end

  root to: 'home#index'

  get 'home/index'
  post 'home/online_search'
  get 'home/completed_search'

  get 'accessibility_statement' => 'guide#accessibility_statement'

  ['400', '422', '500', '503'].each do |error|
    get "/#{error}" => "static##{error}"
  end

  get "/404" => "static#not_found"

  get 'users/deleted' => 'users#deleted', as: 'deleted_users'
  get 'users/search' => 'users#search', as: 'search_users'
  patch 'users/:id/restore' => 'users#restore', as: 'restore_user'
  patch 'users/:id/invite' => 'users#invite', as: 'invite_user'
  devise_for :users, skip: :registrations, controllers: {
    invitations: 'users/invitations',
    passwords: 'users/passwords',
    sessions: 'users/sessions',
    confirmations: 'users/confirmations'
  }
  resources :users
  as :user do
    get 'users/:id/change_password' => 'users/registrations#edit', as: 'edit_user_registration'
    patch 'users/:id/change_password' => 'users/registrations#update', as: 'user_registration'
    get 'users/:id/export_file/:file_id/' => 'users/file_download#show', as: 'user_export_file'
    get 'users/:id/export_file/:file_id/download' => 'users/file_download#download', as: 'user_export_file_download'
  end
end
