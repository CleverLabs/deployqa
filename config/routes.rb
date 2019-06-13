# frozen_string_literal: true

Rails.application.routes.draw do
  default_url_options host: ENV["HOST_NAME"], protocol: "https"

  root "home#index"
  get "/auth/:provider/callback", to: "sessions#create"
  resources :home, only: %i[index]
  resource :sessions, only: %i[show create destroy]
  resources :repos, only: %i[create show index] do
    resources :secrets, only: %i[index create]
  end

  namespace :webhooks do
    resources :github, only: %i[create]
  end

  resources :projects do
    resources :project_instances do
      resource :deploy, only: %i[show create], module: :project_instances
      resource :reload, only: %i[create], module: :project_instances
      resource :update, only: %i[create], module: :project_instances
      resources :database_dumps, only: %i[index show create update], module: :project_instances
      resources :build_actions, only: %i[show], module: :project_instances
    end
    resources :deployment_configurations
  end

  resources :project_instances_counts, only: %i[index]
end
