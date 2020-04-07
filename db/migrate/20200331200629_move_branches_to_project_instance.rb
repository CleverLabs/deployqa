class MoveBranchesToProjectInstance < ActiveRecord::Migration[5.2]
  ProjectInstance = Class.new(ActiveRecord::Base)

  def up
    ProjectInstance.find_each do |project_instance|
      puts project_instance.id

      branches = project_instance.configurations.each_with_object({}) do |configuration, result|
        result[configuration["repo_path"]] = configuration["git_reference"]
      end

      project_instance.update!(branches: branches)
    end
  end
end
