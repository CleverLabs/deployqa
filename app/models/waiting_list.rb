# frozen_string_literal: true

class WaitingList < ApplicationRecord
  validates :email, uniqueness: true
end
