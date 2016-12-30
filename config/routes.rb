# frozen_string_literal: true
Web3::Application.routes.draw do
  require 'sidekiq/web'
  require 'sidekiq/cron/web'
  authenticate :user do
    mount Sidekiq::Web => '/sidekiq'
  end

  devise_for :users

  scope path_names: { new: 'novo', edit: 'uredi', all: 'vse', search: 'isci' } do
    resources :keywords, path: 'kljucne_besede'
    resources :posts, path: 'poste'
    resources :institutions, path: 'institucije'
    resources :inquiries, path: 'vprasanja' do
      get :all, on: :collection
      member do
        get :answer_question
        patch :answer
      end
    end
    resources :articles, path: 'clanki', only: [:index, :show] do
      get :search, on: :collection
    end
    resources :sections, path: 'sekcije'
    resources :issues, path: 'revije', only: [:index, :show]
    resources :orders, path: 'narocila', only: [:new, :create] do
      get :successful, on: :collection, path: 'uspesno'
    end
    resources :copies, path: 'besedila'
    resources :authors, path: 'avtorji', only: [:show]
    resources :news, path: 'pd-vzgojiteljica'
  end

  get '/avtorji-spletne-aplikacije', to: 'pages#authors'
  get '/navodila', to: 'pages#editorial_instructions'

  namespace :admin do
    root to: 'admin#index'
    get :quantities, to: 'admin#quantities'
    get :freeriders, to: 'admin#freeriders'
    get :regional, to: 'admin#regional'
    resources :duplicates do
      get :index_customers, on: :collection
      get :index_authors, on: :collection
      post :merge_customers, on: :member
      post :merge_authors, on: :collection
    end
    resources :entities
    resources :postal_costs, only: :index do
      get :calculate, on: :collection
    end
    resource :articles do
    end
    resource :authors do
    end
    resources :issues do
      member do
        get :edit_cover
        get :edit_document
        patch :cover
        patch :document
      end
    end
    resources :letters do
      get :print, on: :member
    end
    resources :customers do
      post :new_from_order, on: :collection
      get :new_freerider, on: :collection
      post :create_freerider, on: :collection
      get :add_person, on: :member
      get :edit_person, on: :member
      post :create_person, on: :member
      patch :update_person, on: :member
      post :merge_in, on: :member
      get :email_ingestion, on: :collection
      get :email_ingestion_next, on: :collection
    end
    resources :labels, only: [:index, :show] do
      get :print, on: :collection
    end
    resources :subscribers
    resources :posts
    resources :subscriptions do
      put :end_now, on: :member
      put :end_by_end_of_year, on: :member
      put :reinstate, on: :member
      post :new_from_order, on: :collection
    end
    resources :plans
    resources :batches
    resources :remarks
    resources :orders, only: [:index, :show]
    resources :order_forms do
      get :download, on: :member
      put :mark_processed, on: :member
      put :process_it, on: :member
    end
    resources :invoices do
      get :wizard, on: :collection
      get :print_wizard, on: :collection
      get :reversed, on: :collection
      get :unpaid, on: :collection
      get :due, on: :collection
      get :print, on: :member
      get :print_all, on: :collection
      get :einvoice, on: :member
      get :eenvelope, on: :member
      get :pdf, on: :member
      post :email, on: :member
      post :email_due, on: :member
      post :build_for_subscription, on: :collection
      post :build_partial_for_subscription, on: :collection
      put :reverse, on: :member
    end
    resources :offers do
      get :wizard, on: :collection
      get :print_wizard, on: :collection
      get :print, on: :member
      get :print_all, on: :collection
      get :pdf, on: :member
      post :create_for_customer, on: :collection
      post :email, on: :member
      post :email_due, on: :member
    end
    resources :bank_statements do
      post :parse, on: :member
    end
    resources :statement_entries, only: [:show] do
      post :match, on: :member
    end
  end

  # Public token route
  get '/:token', to: 'customers#public_show', as: :token
  post '/oddaja_narocilnice', to: 'customers#ingest_order_form', as: :ingest_order_form

  # You can have the root of your site routed with "root"
  # root to: 'copies#show', id: 'pages#index'
  root to: 'pages#index'
end
