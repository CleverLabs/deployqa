# frozen_string_literal: true

module NavigationHelper
  # rubocop:disable Rails/HelperInstanceVariable
  BREADCRUMBS_MAPPING = {
    "project_instances#index" => {
      text_and_link: [],
      last_text_and_link: proc { ["Instances", project_project_instances_path(@project)] }
    }
  }.freeze
  # rubocop:enable Rails/HelperInstanceVariable

  def user_available_projects
    statuses = ProjectInstanceConstants::Statuses::ALL_ACTIVE.map { |status| ProjectInstance.deployment_statuses[status] }.join(", ")

    Project
      .select("projects.*, COUNT(project_instances) as active_instances")
      .joins("LEFT JOIN project_instances ON project_instances.project_id = projects.id AND project_instances.deployment_status in (#{statuses})")
      .joins(:project_user_roles)
      .where(project_user_roles: { user_id: current_user.id })
      .group("projects.id")
      .order("projects.created_at DESC")
      .includes(:repositories)
  end

  def navigation_breadcrumbs
    breadcrumbs_options = BREADCRUMBS_MAPPING.fetch(controller_action_name)

    tag.nav class: "breadcrumb", 'aria-label': "breadcrumbs" do
      tag.ul do
        concat(navigation_breadcrumbs_links(breadcrumbs_options.fetch(:text_and_link)))
        concat(tag.li(class: "is-active") { link_to(*instance_eval(&breadcrumbs_options.fetch(:last_text_and_link))) })
      end
    end
  end

  def project_avatar(project)
    return project_integration_logo(project, size: "40x40") if project.integration_type != ProjectsConstants::Providers::GITHUB

    image_tag(GithubEntity.find_by(owner: project).data.fetch("avatar_url"), size: "40x40")
  end

  private

  def navigation_breadcrumbs_links(text_and_links)
    text_and_links.inject(html_escape("")) do |result, text_and_link_proc|
      text, link = instance_eval(&text_and_link_proc)
      result << tag.li { link_to text, link }
    end
  end
end
