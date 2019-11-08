class AddIndexToWaitingListEmail < ActiveRecord::Migration[5.2]
  def change
    safety_assured do
      add_index(:waiting_lists, :email, unique: true)
    end
  end
end
