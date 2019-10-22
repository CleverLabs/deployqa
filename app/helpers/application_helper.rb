# frozen_string_literal: true

module ApplicationHelper
  def humanized_constants(collection)
    collection.map { |constant| [constant.humanize, constant] }
  end
end
