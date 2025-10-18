Rails.application.routes.draw do
  resource :session
  resources :passwords, param: :token
  resources :projects do
    resources :test_cases, except: [ :show ]
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

  get "project_members/accept/:token", to: "project_members#accept", as: :accept_invitation
  post "project_members/:id/resend_invitation", to: "project_members#resend_invitation", as: :resend_invitation_project_member

  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Defines the root path route ("/")
  root "projects#index"
end
