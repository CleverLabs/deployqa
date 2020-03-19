# frozen_string_literal: true

class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true

  def flipper_id
    "#{self.class}:#{id}"
  end
end
