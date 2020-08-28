# frozen_string_literal: true

FactoryBot.define do
  factory :project do
    name { "Some project" }
    integration_id { "132qew" }
    integration_type { "github" }

    to_create do |project|
      existing_project = Project.find_by(integration_id: project.integration_id, integration_type: project.integration_type)
      next project.save! unless existing_project

      project.id = existing_project.id
      project.reload
    end
  end
end
