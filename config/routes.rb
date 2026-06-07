Rails.application.routes.draw do
  # Authentication
  resource :session
  resources :passwords, param: :token

  # Academic tools — nested under subjects
  resources :subjects, only: [ :index, :show ] do
    resources :materials, only: [ :index, :show, :new, :create, :destroy ]
    resources :quizzes, only: [ :index, :show, :new, :create, :edit, :update, :destroy ] do
      resources :quiz_answers, only: [ :create ]
      member do
        get :grade
        post :grade_answers
      end
    end
    resources :assignments, only: [ :index, :show, :new, :create, :edit, :update, :destroy ] do
      resources :assignment_submissions, only: [ :create ]
      member do
        get :grade
        post :grade_submissions
      end
    end
    resources :schedules, only: [ :index, :new, :create, :destroy ]
    resources :attendances, only: [ :index, :create ] do
      get :record, on: :collection
    end
  end

  # Feed & comments
  resources :feed, only: [ :index, :show, :create, :edit, :update, :destroy ] do
    resources :comments, only: [ :create ]
    member do
      post :mark_read
      get :read_status
      get :post_actions
    end
  end

  # Chat & messages
  resources :chat_rooms, only: [ :index, :show ] do
    post :create_private, on: :collection
    post :typing, on: :member
    resources :messages, only: [ :create, :destroy ]
  end

  # Profile (single resource per user)
  resource :profile, only: [ :show, :edit, :update ]

  # Admin back office
  namespace :admin do
    get "/", to: "dashboard#index"
    resources :colleges
    resources :departments
    resources :subjects do
      resources :enrollments, only: [ :create, :destroy ]
    end
    resources :users
    resources :audit_logs, only: [ :index, :show ]
  end

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Defines the root path route ("/")
  root "home#index"
end
