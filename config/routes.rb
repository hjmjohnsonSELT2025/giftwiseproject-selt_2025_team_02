Rails.application.routes.draw do
  get "ai_suggestions/index"
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Defines the root path route ("/")
  # root "posts#index"

  resources :sessions, only: [ :new, :create, :destroy ]

  resources :recipients do
    member do
      post :generate_gift
      post :add_event
      get :generate_gift, to: "recipients#show"
      get :create_birthday_event
      post :create_birthday_event
    end
    resources :gift_lists do
      resources :gifts do
        resources :gift_offers, only: [ :new, :create, :index ]
      end
    end
  end
  resources :events do
    resources :event_recipients, only: [] do
      member do
        get :show
      end
    end
    post :add_collaborator, on: :member
  end

  resources :users, only: [ :new, :create, :show, :edit, :update, :destroy ] do
    post :add_friend, on: :member
    delete :remove_friend, on: :member
  end
  resources :gifts do
    member do
      post :refresh_offers
    end
  end
  resources :gift_lists do
    resources :gifts
  end
  resources :events do
    member do
      post :add_recipient
      delete "remove_recipient/:event_recipient_id", action: :remove_recipient, as: :remove_recipient
    end
  end

  resources :event_recipient_budgets

  get    "/login",  to: "sessions#new",     as: :login
  post   "/login",  to: "sessions#create"
  delete "/logout", to: "sessions#destroy", as: :logout
  get "/homepage", to: "home#show", as: :homepage
  get "/signup", to: "users#new", as: :signup
  get "/auth/google_oauth2/callback", to: "sessions#google_auth"
  get "/auth/failure", to: redirect("/login")


  root "sessions#new"
  if Rails.env.development?
    mount LetterOpenerWeb::Engine, at: "/letter_opener"
  end
  # catch all for wrong indexes
  match "*path", to: "application#handle_routing_error", via: :all
end
