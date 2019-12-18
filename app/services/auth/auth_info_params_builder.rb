# frozen_string_literal: true

module Auth
  class AuthInfoParamsBuilder
    USER_API_CLIENT = {
      OmniauthConstants::GITHUB => ProviderAPI::Github::UserClient,
      OmniauthConstants::GITLAB => ProviderAPI::Gitlab::UserClient
    }.freeze

    def initialize(omniauth_info_presenter, user_reference = nil)
      @omniauth_info_presenter = omniauth_info_presenter
      @user_reference = user_reference
    end

    def call
      params = @omniauth_info_presenter.to_auth_info_params
      load_email(params)

      @user_reference.present? ? params.merge(user_reference: @user_reference) : params
    end

    private

    def load_email(params)
      return if params[:email].present?

      api_client = USER_API_CLIENT.fetch(@omniauth_info_presenter.provider).new(@omniauth_info_presenter.token)
      email = api_client.emails.find { |email_info| email_info[:primary] }.fetch(:email)
      params[:email] = email
    end
  end
end
