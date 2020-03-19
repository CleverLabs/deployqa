# frozen_string_literal: true

class FeaturesPolicy < ApplicationPolicy
  def show?
    user.system_role == UserConstants::SystemRoles::ADMIN
  end
end
