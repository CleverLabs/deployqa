# frozen_string_literal: true

require "sidekiq/web"
require "routes/logged_user_constraint"

Rails.application.routes.draw do
  default_url_options host: ENV["HOST_NAME"], protocol: ENV["HOST_NAME"].include?("localhost") ? "http" : "https"

  root "landings#index"
  get "/landings", to: "landings#create"

  get "/auth/slack/callback", to: "slack/authentications#create"
  get "/auth/failure", to: "slack/authentications#show"
  get "/auth/:provider/callback", to: "sessions#create"
  post "/auth/:provider", to: "sessions#show", as: "omniauth"

  constraints Routes::LoggedUserConstraint.new(SidekiqPolicy) do
    mount Sidekiq::Web => "/sidekiq"
  end

  constraints Routes::LoggedUserConstraint.new(FeaturesPolicy) do
    mount Flipper::UI.app(Flipper) => "/flipper"
  end

  resource :sessions, only: %i[show create destroy]
  resources :users, only: %i[show]

  namespace :admin do
    resource :dashboard, only: %i[show]
  end

  namespace :webhooks do
    resources :github, only: %i[create]
    resources :gitlab_integrations, only: %i[create]
  end

  resources :projects, only: %i[index new show create] do
    resources :project_instances, only: %i[index show new create destroy] do
      resource :deploy, only: %i[show create], module: :project_instances
      resource :redeploy, only: %i[create], module: :project_instances
      resource :reload, only: %i[create], module: :project_instances
      resource :update, only: %i[create], module: :project_instances
      resource :configuration, only: %i[edit update], module: :project_instances
      resource :log, only: %i[show], module: :project_instances
      resources :database_dumps, only: %i[index show create update], module: :project_instances
      resources :build_actions, only: %i[show], module: :project_instances
      resources :addons, only: %i[index], module: :project_instances
    end
    resources :repositories, only: %i[new create edit update]
    resources :repository_statuses, only: %i[update]
    resources :project_user_roles, only: %i[destroy create]

    nested do
      scope module: :gitlab_integration, path: "gitlab", as: "gitlab" do
        resources :repositories, only: %i[new create edit update]
      end
    end
  end

  scope module: :gitlab_integration, path: "gitlab", as: "gitlab" do
    resources :projects, only: %i[new create]
  end

  resources :project_instances_counts, only: %i[index]
end
