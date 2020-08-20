# frozen_string_literal: true

module Auth
  class AuthInfoParamsBuilder
    USER_API_CLIENT = {
      OmniauthConstants::GITHUB => ::ProviderApi::Github::UserClient,
      OmniauthConstants::GITLAB => ::ProviderApi::Gitlab::UserClient
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

      # TODO: why do we need USER_API_CLIENT? GitLab always have an email and there is no :email method in ProviderApi::Gitlab::UserClient
      api_client = USER_API_CLIENT.fetch(@omniauth_info_presenter.provider).new(@omniauth_info_presenter.token)
      email = api_client.emails.find { |email_info| email_info[:primary] }[:email]
      params[:email] = email
    end
  end
end
