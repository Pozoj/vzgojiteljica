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
    end
    resources :copies, path: 'besedila'
    resources :authors, path: 'avtorji'
    resources :news, path: 'pd-vzgojiteljica'
  end

  get '/avtorji-spletne-aplikacije', to: 'pages#authors'

  namespace :admin do
    root to: 'admin#index'
    get :quantities, to: 'admin#quantities'
    get :freeriders, to: 'admin#freeriders'
    resources :entities
    resources :customers do
      post :new_from_order, on: :member
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
      get :print, on: :member
      get :print_all, on: :collection
      post :build_for_subscription, on: :collection
    end
    resources :bank_statements do
      post :parse, on: :member
    end
    resources :statement_entries
  end

  # You can have the root of your site routed with "root"
  # root to: 'copies#show', id: 'pages#index'
  root to: 'pages#index'
end
