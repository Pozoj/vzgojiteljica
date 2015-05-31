Web3::Application.routes.draw do
  resources :line_items

  devise_for :users

  scope :path_names => {:new => "novo", :edit => "uredi", :all => "vse", :search => "isci"} do
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
    resources :articles, path: 'clanki' do
      collection do
        get :all, :search
      end
    end
    resources :sections, path: 'sekcije'
    resources :issues, path: 'revije' do
      get :all, on: :collection
      member do
        get :edit_cover
        get :edit_document
        patch :cover
        patch :document
      end
    end
    resources :orders, path: 'narocila' do
      put :mark_processed, on: :member
      get :successful, on: :collection, path: 'uspesno'
    end
    resources :copies, path: 'besedila'
    resources :authors, path: 'avtorji'
    resources :news, path: 'pd-vzgojiteljica'
  end

  get '/avtorji-spletne-aplikacije', to: 'pages#authors'
  get '/navodila', to: 'pages#editorial_instructions'

  namespace :admin do
    root to: 'admin#index'
    get :quantities, to: 'admin#quantities'
    get :freeriders, to: 'admin#freeriders'
    get :regional, to: 'admin#regional'
    resources :entities
    resources :customers do
      post :new_from_order, on: :member
      get :new_freerider, on: :collection
      post :create_freerider, on: :collection
    end
    resources :labels, only: [:index, :show]
    resources :subscribers
    resources :posts
    resources :subscriptions do
      put :end_now, on: :member
      put :end_by_end_of_year, on: :member
      put :reinstate, on: :member
    end
    resources :plans
    resources :batches
    resources :remarks
    resources :invoices do
      get :unpaid, on: :collection
      get :print, on: :member
      get :print_all, on: :collection
      get :einvoice, on: :member
      get :eenvelope, on: :member
      get :pdf, on: :member
      post :build_for_subscription, on: :collection
    end
    resources :bank_statements do
      post :parse, on: :member
    end
    resources :statement_entries, only: [:show] do
      post :match, on: :member
    end
  end

  # You can have the root of your site routed with "root"
  # root to: 'copies#show', id: 'pages#index'
  root to: 'pages#index'
end
