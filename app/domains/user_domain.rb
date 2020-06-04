# frozen_string_literal: true

class UserDomain
  def self.system_user
    user = User.find_by(system_role: UserConstants::SystemRoles::AUTOMATIC_SYSTEM, full_name: "System")
    new(user, user.user_references.first)
  end

  attr_reader :user_reference_record

  def initialize(user, user_reference)
    @user_record = user
    @user_reference_record = user_reference
  end
end
