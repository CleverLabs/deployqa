# frozen_string_literal: true

class GitlabRepositoriesInfo < ApplicationRecord
  belongs_to :project, optional: false

  validates :data, presence: true
end
