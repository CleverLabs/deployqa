# frozen_string_literal: true

class BuildAction < ApplicationRecord
  belongs_to :author, class_name: "User", foreign_key: :author_id
  belongs_to :project_instance

  validates :action, presence: true

  enum action: %i[create_instance update_instance reload_instance destroy_instance]
end