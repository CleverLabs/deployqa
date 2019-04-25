# frozen_string_literal: true

class Repo < ApplicationRecord
  belongs_to :user
  has_many :secrets
end
