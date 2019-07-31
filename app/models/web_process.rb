# frozen_string_literal: true

class WebProcess < ApplicationRecord
  has_paper_trail

  belongs_to :deployment_configuration, required: true

  validates :name, :command, presence: true
end
