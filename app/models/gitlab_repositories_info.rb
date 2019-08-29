# frozen_string_literal: true

class GitlabRepositoriesInfo < ApplicationRecord
  belongs_to :project, required: true

  validates :data, presence: true
end
