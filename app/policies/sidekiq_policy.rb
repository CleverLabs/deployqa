# frozen_string_literal: true

class SidekiqPolicy < ApplicationPolicy
  def show?
    user.system_role == UserConstants::SystemRoles::ADMIN
  end
end
