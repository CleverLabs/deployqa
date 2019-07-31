# frozen_string_literal: true

class ApplicationJob < ActiveJob::Base
  before_perform do
    PaperTrail.request.whodunnit = "job:#{self.class.name}"
  end
end
