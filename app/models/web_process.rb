# frozen_string_literal: true

class WebProcess < ApplicationRecord
  has_paper_trail

  belongs_to :repository, optional: false

  validates :name, :command, presence: true
end
