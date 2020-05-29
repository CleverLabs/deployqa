# frozen_string_literal: true

class SleepingInstance < ApplicationRecord
  has_paper_trail

  belongs_to :project_instance, required: true

  validates :urls, :application_name, presence: true
end
