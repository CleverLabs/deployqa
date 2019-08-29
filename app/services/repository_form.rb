# frozen_string_literal: true

class RepositoryForm
  include ShallowAttributes

  attribute :path, String
  attribute :env_variables, Hash
  attribute :name, String, default: ->(form, _attribute) { form.path.present? && form.path.split(":").last.gsub(/\.git$/, "") }
  attribute :status, String, default: RepositoryConstants::ACTIVE
  attribute :integration_type, String, default: ProjectsConstants::Providers::VIA_SSH
  attribute :integration_id, String, default: ->(_, _) { SecureRandom.uuid }
  attribute :project, Project
  attribute :addon_ids, Array, of: Integer
  attribute :web_processes_attributes, Array, of: Hash

  alias _env_variables= env_variables=
  def env_variables=(value)
    self._env_variables = Hash[value.split("\n").map { |line| line.tr("\r", "").split(": ") }]
  end

  def web_processes_attributes=(params)
    return if params.blank?

    @web_processes_attributes = mark_empty_processes_to_destroy(params.values)
                                .select { |attributes| attributes[:command].present? || attributes[:_destroy] }

    @attributes[:web_processes_attributes] = @web_processes_attributes
  end

  private

  def mark_empty_processes_to_destroy(attributes_array)
    attributes_array.map do |attributes|
      attributes[:_destroy] = true if attributes[:id].present? && attributes[:command].blank?
      attributes
    end
  end
end
