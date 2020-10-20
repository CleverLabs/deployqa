# frozen_string_literal: true

require "sidekiq/web"
require "routes/logged_user_constraint"

Rails.application.routes.draw do
  use_doorkeeper
  default_url_options host: ENV["HOST_NAME"], protocol: (ENV["HOST_NAME"] || "").include?("localhost") ? "http" : "https"

  root "landings#index"
  get "/landings", to: "landings#create"
  get "/roles/:role", to: "landings#roles"
  get "/pricing", to: "landings#pricing"
  get "/faq", to: "landings#faq"

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

  resource :dashboards, only: %i[show]
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
    resources :billings, only: %i[index]
    resources :repository_statuses, only: %i[update]
    resources :project_user_roles, only: %i[index destroy create]
    resources :notifications, only: %i[index]

    nested do
      scope module: :gitlab_integration, path: "gitlab", as: "gitlab" do
        resources :repositories, only: %i[new create edit update]
      end
    end
  end

  scope module: :gitlab_integration, path: "gitlab", as: "gitlab" do
    resources :projects, only: %i[new create]
  end

  namespace :api do
    namespace :v1 do
      resources :project_instances, only: %i[], constraints: { project_instance_id: /[\w+.\-:]+/ } do
        resource :wake_up, only: :create, module: :project_instances do
          resource :status, only: :show
        end
      end
    end
  end
end
