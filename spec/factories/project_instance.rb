# frozen_string_literal: true

FactoryBot.define do
  factory :project_instance do
    project { Project.first || association(:project) }
    name { |number| "some_project_instance_#{number}" }
    deployment_status { "running" }
    configurations { [] }
  end
end
