# frozen_string_literal: true

Rails.application.routes.draw do
  root "home#index"
  get "/auth/:provider/callback", to: "sessions#create"
  resources :home, only: %i[index]
  resource :sessions, only: %i[show create destroy]
  resources :repos, only: %i[create show index] do
    resources :secrets, only: %i[index create]
  end

  resources :projects do
    namespace :webhooks do
      resources :github, only: %i[create]
    end
    resources :project_instances do
      resource :reload, only: %i[create], module: :project_instances
      resource :update, only: %i[create], module: :project_instances
      resources :database_dumps, only: %i[index show create update], module: :project_instances
      resources :build_actions, only: %i[show], module: :project_instances
    end
    resources :deployment_configurations
  end

  resources :project_instances_counts, only: %i[index]
end
