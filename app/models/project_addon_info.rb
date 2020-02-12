# frozen_string_literal: true

class ProjectAddonInfo < ApplicationRecord
  has_paper_trail

  belongs_to :project
  belongs_to :addon
end
