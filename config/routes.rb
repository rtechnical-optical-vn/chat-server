Rails.application.routes.draw do
  get "/health", to: "health#show"
  get "/", to: "health#index"

  mount ActionCable.server => "/cable"

  namespace :api do
    post "sessions", to: "sessions#create"
    get "sessions/:session_id/messages", to: "sessions#messages"
    post "sessions/:session_id/messages", to: "sessions#create_message"

    namespace :admin do
      get "sessions", to: "sessions#index"
      get "sessions/:session_id/messages", to: "sessions#messages"
      post "sessions/:session_id/messages", to: "sessions#create_message"
      patch "sessions/:session_id", to: "sessions#update"
    end
  end
end
