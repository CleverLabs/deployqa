# frozen_string_literal: true

module GitlabIntegration
  class MergeRequest
    attr_reader :mr_attributes, :repository, :user

    def initialize(payload)
      @repository = payload["project"]
      @mr_attributes = payload["object_attributes"]
      @user = payload["user"]
    end

    def number
      mr_attributes["iid"]
    end

    def repo_name
      repository["name"]
    end

    def repo_id
      repository["id"]
    end

    def full_repo_name
      repository["path_with_namespace"]
    end

    def branch
      mr_attributes["source_branch"]
    end

    def author_id
      mr_attributes.fetch("author_id")
    end

    def edited_by_id
      mr_attributes.fetch("last_edited_by_id") # Maybe the key must be "updated_by_id"
    end

    def user_name
      user["name"]
    end
  end
end
