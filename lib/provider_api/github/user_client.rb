# frozen_string_literal: true

module ProviderApi
  module Github
    class UserClient
      delegate :find_user_installations, :emails, to: :@client

      def initialize(user_token)
        @client = Octokit::Client.new(access_token: user_token)
      end
    end
  end
end
