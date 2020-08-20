# frozen_string_literal: true

module ProviderApi
  module Gitlab
    class ProjectBot
      def initialize(deploy_token)
        @deploy_token = deploy_token
      end

      def clone_repository_uri(repo_path)
        "https://#{@deploy_token}@gitlab.com/#{repo_path}.git"
      end
    end
  end
end
