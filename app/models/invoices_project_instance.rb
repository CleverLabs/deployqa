# frozen_string_literal: true

class InvoicesProjectInstance < ApplicationRecord
  has_paper_trail

  belongs_to :invoice, required: true
  belongs_to :project_instance, required: true
end
