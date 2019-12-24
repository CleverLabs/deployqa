# frozen_string_literal: true

class UserPolicy < ApplicationPolicy
  def show?
    return true if user.system_role == UserConstants::SystemRoles::ADMIN

    user.actual_user == record
  end
end
