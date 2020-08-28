# frozen_string_literal: true

FactoryBot.define do
  factory :project_instance do
    project { Project.first || association(:project) }
    name { "some_project_instance" }
    deployment_status { "running" }
    configurations { [] }
  end
end
