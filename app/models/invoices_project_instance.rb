# frozen_string_literal: true

class InvoicesProjectInstance < ApplicationRecord
  has_paper_trail

  belongs_to :invoice, optional: false
  belongs_to :project_instance, optional: false
end
