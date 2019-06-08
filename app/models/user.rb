# frozen_string_literal: true

class User < ApplicationRecord
  has_many :repos
  has_many :project_user_roles
  has_many :projects, through: :project_user_roles
end
