# frozen_string_literal: true

class ApplicationJob < ActiveJob::Base
  include Rollbar::ActiveJob

  before_perform do
    PaperTrail.request.whodunnit = "job:#{self.class.name}"
  end
end
