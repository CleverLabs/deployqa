class CreateUserReferences < ActiveRecord::Migration[5.2]
  def change
    create_table :user_references do |t|
      t.references :user, index: true, foreign_key: true, null: true
      t.string :full_name, null: false
      t.string :auth_uid, null: false
      t.integer :auth_provider, null: false

      t.timestamps

      t.index [:auth_uid, :auth_provider], unique: true
    end
  end
end
