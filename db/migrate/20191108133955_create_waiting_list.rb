class CreateWaitingList < ActiveRecord::Migration[5.2]
  def change
    create_table :waiting_lists do |t|
      t.string :email, null: false

      t.timestamps null: false
    end
  end
end
