# frozen_string_literal: true

class RepositoriesAddon < ApplicationRecord
  has_paper_trail

  belongs_to :repository
  belongs_to :addon
end
