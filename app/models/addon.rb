# frozen_string_literal: true

class Addon < ApplicationRecord
  has_paper_trail

  validates :name, presence: true

  enum integration_provider: AddonConstants::IntegrationProviders::ALL
  enum addon_type: AddonConstants::Types::ALL
end
