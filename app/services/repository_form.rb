# frozen_string_literal: true

class RepositoryForm
  include ShallowAttributes

  attribute :path, String
  attribute :runtime_env_variables, Hash
  attribute :build_env_variables, Hash
  attribute :name, String, default: ->(form, _attribute) { form.path.present? && form.path.split(":").last.gsub(/\.git$/, "") }
  attribute :status, String, default: RepositoryConstants::ACTIVE
  attribute :integration_type, String, default: ProjectsConstants::Providers::VIA_SSH
  attribute :integration_id, String, default: ->(_, _) { SecureRandom.uuid }
  attribute :project, Project
  attribute :addon_ids, Array, of: Integer
  attribute :web_processes_attributes, Array, of: Hash
  attribute :build_type, String
  attribute :seeds_command, String
  attribute :schema_load_command, String
  attribute :migration_command, String

  alias _runtime_env_variables= runtime_env_variables=
  def runtime_env_variables=(value)
    self._runtime_env_variables = Hash[value.values.map { |key_value| [key_value["key"], key_value["value"]] }].compact
  end

  alias _build_env_variables= build_env_variables=
  def build_env_variables=(value)
    self._build_env_variables = Hash[value.values.map { |key_value| [key_value["key"], key_value["value"]] }].compact
  end

  def web_processes_attributes=(params)
    return if params.blank?

    @web_processes_attributes = mark_empty_processes_to_destroy(params.values)
                                .select { |attributes| attributes[:command].present? || attributes[:_destroy] }

    @web_processes_attributes.each { |attributes| attributes[:expose_port] = 80 if attributes[:name] == "web" }
    @attributes[:web_processes_attributes] = @web_processes_attributes
  end

  alias _status= status=
  def status=(value)
    self._status = build_type == RepositoryConstants::PRIVATE_GEM ? RepositoryConstants::INACTIVE : value
  end

  private

  def mark_empty_processes_to_destroy(attributes_array)
    attributes_array.map do |attributes|
      attributes[:_destroy] = true if attributes[:id].present? && attributes[:command].blank?
      attributes
    end
  end
end
