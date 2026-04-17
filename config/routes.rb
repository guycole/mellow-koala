Rails.application.routes.draw do
  root "tasks#index"
  resources :tasks, only: [:index]
  resources :box_scores, only: [:index]
  resource :session, only: [:new, :create, :destroy]
  resources :passwords, param: :token

  namespace :admin do
    root "dashboard#index"
    resources :import_logs, only: [:index, :show]
  end

  get "up" => "rails/health#show", as: :rails_health_check
end
