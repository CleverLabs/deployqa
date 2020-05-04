class AddDockerfileToWebProcesses < ActiveRecord::Migration[5.2]
  def change
    add_column :web_processes, :dockerfile, :string
  end
end
