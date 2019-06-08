class DeleteOwnerIdFromProjects < ActiveRecord::Migration[5.2]
  def change
    remove_column :projects, :owner_id, :string, null: false
  end
end
