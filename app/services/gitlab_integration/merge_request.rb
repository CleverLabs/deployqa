# frozen_string_literal: true

module GitlabIntegration
  class MergeRequest
    def initialize(project_id, merge_request_id)
      @project_id = project_id
      @merge_request_id = merge_request_id
      @gitlab_client = ::ProviderAPI::Gitlab::BotClient.new
    end

    def update_description(text)
      original_desc = merge_request.description
      new_desc = [original_desc, "\r\n\r\n", text].join
      gitlab_client.update_mr_description(project_id, merge_request_id, new_desc)
    end

    def update_info_comment(text)
      discussions = gitlab_client.merge_request_discussions(project_id, merge_request_id)
      deployqa_comment = find_deployqa_comment(discussions)

      deployqa_comment ? update_comment(deployqa_comment.id, deployqa_comment.notes.first["id"], text) : create_comment(text)
    end

    private

    attr_reader :project_id, :merge_request_id, :gitlab_client

    def find_deployqa_comment(discussions)
      return unless discussions

      user_discussions = discussions.filter { |discussion| discussion.notes.all? { |comment| comment["system"] == false } }
      user_discussions.find { |discussion| discussion.notes.first.dig("author", "id") == ENV["GITLAB_DEPLOYQA_BOT_ID"].to_i }
    end

    def update_comment(discussion_id, note_id, text)
      gitlab_client.update_mr_comment(project_id, merge_request_id, discussion_id, note_id, text)
    end

    def create_comment(text)
      gitlab_client.create_mr_comment(project_id, merge_request_id, text)
    end

    def merge_request
      gitlab_client.merge_request(project_id, merge_request_id)
    end
  end
end
