class AddGenerateDomainToWebProcesses < ActiveRecord::Migration[5.2]
  def change
    safety_assured do
      add_column :web_processes, :generate_domain, :boolean, default: true, null: false
    end
  end
end
