class AddConfigurationsToBuildAction < ActiveRecord::Migration[5.2]
  def change
    safety_assured do
      add_column :build_actions, :configurations, :jsonb, default: {}, null: false
    end
  end
end
