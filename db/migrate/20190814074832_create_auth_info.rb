class CreateAuthInfo < ActiveRecord::Migration[5.2]
  def change
    create_table :auth_infos do |t|
      t.belongs_to :user, index: { unique: true }, foreign_key: true, null: false
      t.jsonb :data, null: false, default: {}

      t.timestamps
    end
  end
end
