# frozen_string_literal: true

class WebProcess < ApplicationRecord
  belongs_to :deployment_configuration, required: true

  validates :name, :command, presence: true
end
