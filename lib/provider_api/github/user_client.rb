# frozen_string_literal: true

module ProviderAPI
  module Github
    class UserClient
      delegate :find_user_installations, to: :@client

      def initialize(user_token)
        @client = Octokit::Client.new(access_token: user_token)
      end
    end
  end
end
