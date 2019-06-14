# frozen_string_literal: true

class GithubEntity < ApplicationRecord
  belongs_to :owner, polymorphic: true

  validates :data, presence: true

  def self.ensure_info_exists(owner, data)
    find_or_create_by(owner: owner) do |github_entity|
      github_entity.data = data
    end
  end
end
