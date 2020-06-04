class AddTimestampsToNomadReferences < ActiveRecord::Migration[5.2]
  NomadReference = Class.new(ActiveRecord::Base)

  def up
    safety_assured do
      add_timestamps :nomad_references, null: true 

      starting_date = DateTime.new(2020, 1, 1)
      NomadReference.update_all(created_at: starting_date, updated_at: starting_date)

      change_column_null :nomad_references, :created_at, false
      change_column_null :nomad_references, :updated_at, false
    end
  end
end
