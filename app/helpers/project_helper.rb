# frozen_string_literal: true

module ProjectHelper
  NEW_CONFIGURATION_URL_MAPPING = {
    ProjectsConstants::Providers::GITHUB => ->(helper, _project) { helper.github_router.additional_installation_url },
    ProjectsConstants::Providers::GITLAB => ->(helper, project) { helper.new_project_gitlab_repository_path(project) },
    ProjectsConstants::Providers::VIA_SSH => ->(helper, project) { helper.new_project_repository_path(project) }
  }.freeze

  def new_configuration_url(project)
    NEW_CONFIGURATION_URL_MAPPING.fetch(project.integration_type).call(self, project)
  end

  def link_to_project_orgatnization(project)
    return project_integration_logo(project) if project.integration_type == ProjectsConstants::Providers::VIA_SSH

    link_to(github_router.page_url(project.name), target: :_blank) do
      project_integration_logo(project)
    end + " "
  end

  def project_integration_logo(project)
    return image_pack_tag("media/images/logos/git-logo-black.png", size: "32x32") if project.integration_type == ProjectsConstants::Providers::VIA_SSH

    image_pack_tag("media/images/logos/github-logo.png", size: "32x32") if project.integration_type == ProjectsConstants::Providers::GITHUB
  end
end
