# frozen_string_literal: true

class SecretsController < ApplicationController
  def index
    render json: secrets
  end

  def create
    secret = load_repo.secrets.create!(secret_params)
    render json: secret.attributes
  end

  private

  def secrets
    load_repo.secrets.map(&:attributes)
  end

  def secret_params
    params.require(:secret).permit(:key, :value)
  end

  def load_repo
    current_user.repos.find(params[:repo_id])
  end
end
