# frozen_string_literal: true

class NomadReference < ApplicationRecord
  has_paper_trail

  belongs_to :project_instance
end
