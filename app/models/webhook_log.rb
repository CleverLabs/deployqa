# frozen_string_literal: true

class WebhookLog < ApplicationRecord
  enum integration_type: ProjectsConstants::Providers::ALL
end
