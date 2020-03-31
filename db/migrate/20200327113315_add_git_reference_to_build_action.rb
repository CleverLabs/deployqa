# frozen_string_literal: true

class AddGitReferenceToBuildAction < ActiveRecord::Migration[5.2]
  def change
    add_column :build_actions, :git_reference, :string
  end
end
