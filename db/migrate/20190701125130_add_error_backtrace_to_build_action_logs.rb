class AddErrorBacktraceToBuildActionLogs < ActiveRecord::Migration[5.2]
  def change
    add_column :build_action_logs, :error_backtrace, :string
  end
end
