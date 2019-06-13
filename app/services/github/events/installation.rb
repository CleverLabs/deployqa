# frozen_string_literal: true

module Github
  module Events
    class Installation
      include ShallowAttributes

      GithubPerson = Struct.new(:id, :name)
      GithubRepo = Struct.new(:id, :name, :full_name)

      attribute :payload, Hash

      def installation_id
        payload.dig("installation", "id")
      end

      def initiator_info
        GithubPerson.new(payload.dig("sender", "id"), payload.dig("sender", "login"))
      end

      def organization_info
        GithubPerson.new(payload.dig("installation", "account", "id"), payload.dig("installation", "account", "login"))
      end

      def repos
        transform_repo_infos(payload.fetch("repositories"))
      end

      def added_repos
        transform_repo_infos(payload.fetch("repositories_added"))
      end

      def removed_repos
        transform_repo_infos(payload.fetch("repositories_removed"))
      end

      private

      def transform_repo_infos(infos)
        infos.map do |repo_hash|
          GithubRepo.new(repo_hash.fetch("id"), repo_hash.fetch("name"), repo_hash.fetch("full_name"))
        end
      end
    end
  end
end
