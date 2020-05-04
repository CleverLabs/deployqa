class AddExposePortToWebProcesses < ActiveRecord::Migration[5.2]
  def change
    add_column :web_processes, :expose_port, :integer
  end
end
