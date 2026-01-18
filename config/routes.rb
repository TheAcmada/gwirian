Rails.application.routes.draw do
  # Public routes (no workspace required)
  resource :session do
    scope module: :sessions do
      resource :magic_link, only: [ :show, :create ]
    end
  end

  get "up" => "rails/health#show", as: :rails_health_check

  # MCP (Model Context Protocol) endpoint
  post "mcp" => "mcp#handle"

  # Workspace management (outside workspace scope)
  resources :workspaces, only: [:index, :new, :create]

  # Workspace member actions (outside workspace scope)
  patch "workspace_members/:id/accept", to: "workspace_members#accept", as: :accept_workspace_invitation
  patch "workspace_members/:id/rejoin", to: "workspace_members#rejoin", as: :rejoin_workspace

  # API routes (outside workspace scope for now)
  namespace :api do
    namespace :v1 do
      get "projects", to: "projects#index"
      get "projects/:project_id", to: "projects#show"
      resources :features, only: [ :index, :show, :create, :update, :destroy ], path: "projects/:project_id/features" do
        resources :scenarios, only: [ :index, :show, :create, :update, :destroy ] do
          resources :scenario_executions, only: [ :index, :show, :create, :update, :destroy ]
        end
      end
    end
  end

  # Workspace-scoped routes (middleware extracts slug and sets Current.workspace)
  resources :projects do
    resources :features, only: [ :index, :show, :create, :update, :destroy ] do
      member do
        post :add_tag
        delete :remove_tag
        get :start_execution
        get :select_scenarios
        post :select_scenarios
        get :execute_scenarios
        post :execute_scenarios
      end
      resources :scenarios, only: [ :create, :update, :destroy ] do
        collection do
          post :reorder
        end
        resources :steps, only: [ :create, :update, :destroy ]
      end
    end
    member do
      get :history
      post :add_member
      delete :remove_member
      patch :update_member
    end
  end

  resources :workspace_members, only: [ :index, :create, :update, :destroy ] do
    member do
      post :resend_invitation
    end
  end

  resources :users, except: [ :show ] do
    member do
      post :generate_api_token
      delete :revoke_api_token
    end
  end

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Root redirects to workspace selector or first workspace
  root "workspaces#index"
end
