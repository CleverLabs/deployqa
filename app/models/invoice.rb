# frozen_string_literal: true

class Invoice < ApplicationRecord
  has_paper_trail

  belongs_to :project, required: true
  has_many :invoices_project_instances
  has_many :project_instances, through: :invoices_project_instances

  validates :start_time, :end_time, presence: true
end
