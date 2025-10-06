Rails.application.routes.draw do
  resource :session
  resources :passwords, param: :token
  resources :projects do
    member do
      post :add_member
      delete :remove_member
      patch :update_member
    end
  end
  resources :users, except: [ :show ] do
    member do
      patch :update_password
    end
  end

  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Defines the root path route ("/")
  root "projects#index"
end
