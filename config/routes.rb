Rails.application.routes.draw do
  root "portal/components#index"

  # Portal UI (public)
  scope module: :portal do
    resources :components, only: [ :index, :show ], param: :slug do
      member do
        get :collection
      end
    end
    get "carousel", to: "carousel#show", as: :carousel
  end

  # Ingestion API (authenticated per-component)
  namespace :api do
    resources :components, only: [] do
      resources :configuration_snapshots, only: [ :create ]
      resources :collection_snapshots, only: [ :create ]
    end
  end

  # Health check
  get "up", to: "rails/health#show", as: :rails_health_check
end
