class FillExposePortInWebProcesses < ActiveRecord::Migration[5.2]
  WebProcess = Class.new(ActiveRecord::Base)

  def up
    WebProcess.where(name: "web").find_each do |web_process|
      puts web_process.id

      web_process.update!(expose_port: 80)
    end
  end
end
