# frozen_string_literal: true

Flipper.configure do |config|
  config.default do
    adapter = Flipper::Adapters::ActiveRecord.new
    flipper = Flipper.new(adapter)
  end
end
