# frozen_string_literal: true

module ProjectHelper
  NEW_CONFIGURATION_URL_MAPPING = {
    ProjectsConstants::Providers::GITHUB => ->(_helper, _project) { Github::Router.new.additional_installation_url },
    ProjectsConstants::Providers::VIA_SSH => ->(helper, project) { helper.new_project_deployment_configuration_path(project) }
  }.freeze

  def new_configuration_url(project)
    NEW_CONFIGURATION_URL_MAPPING.fetch(project.integration_type).call(self, project)
  end

  def link_to_project_orgatnization(project)
    return if project.integration_type == ProjectsConstants::Providers::VIA_SSH

    link_to(Github::Router.new.page_url(project.name), target: :_blank) do
      image_pack_tag("media/images/logos/github-logo.png")
    end + " "
  end
end
