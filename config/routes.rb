Web3::Application.routes.draw do
  devise_for :users

  resources :keywords
  resources :posts
  resources :institutions
  resources :inquiries do
    get :all, on: :collection
    member do
      get :answer_question
      post :answer
    end
  end
  resources :articles do
    collection do
      get :all, :search
    end
  end
  resources :sections
  resources :issues do
    get :all, on: :collection
    member do
      get :edit_cover
      get :edit_document
      patch :cover
      patch :document
    end
  end
  resources :orders
  resources :copies
  resources :authors
  resources :news

  # You can have the root of your site routed with "root"
  # root to: 'copies#show', id: 'pages#index'
  root to: 'pages#index'
end
