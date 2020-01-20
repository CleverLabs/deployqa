class CreateEmailWhitelist < ActiveRecord::Migration[5.2]
  def change
    create_table :email_whitelists do |t|
      t.string :email, null: false

      t.timestamps null: false

      t.index :email, unique: true
    end
  end
end
