class FillAuthInfoPrimary < ActiveRecord::Migration[5.2]
  User = Class.new(ActiveRecord::Base)

  class UserReference < ActiveRecord::Base
    has_one :auth_info
  end

  class AuthInfo < ActiveRecord::Base
    belongs_to :user_reference
  end

  def up
    AuthInfo.where.not(email: duplicate_emails).update_all(primary: true)

    duplicate_emails.each do |email|
      auth_infos = AuthInfo.where(email: email).to_a

      auth_infos.first.update!(primary: true)
      auth_infos.drop(1).each { |auth_info| auth_info.update!(primary: false) }
    end
  end

  def down
    # Irreversible migration
  end

  private

  def duplicate_emails
    AuthInfo.group(:email).having("count(id) > 1").pluck(:email)
  end
end
