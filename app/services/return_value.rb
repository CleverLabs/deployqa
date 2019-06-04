# frozen_string_literal: true

class ReturnValue
  include ShallowAttributes
  STATUSES = %i[ok error no_action].freeze

  attribute :object, Object
  attribute :status, String, present: true
  attribute :errors, Object

  delegate :ok?, :error?, :no_action?, to: :status

  alias _status= status=

  def status=(value)
    raise ArgumentError, value unless value.in?(STATUSES)

    self._status = value.to_s.inquiry
  end

  def errors=(value)
    value.is_a?(::Hash) ? super(value) : super(Array(value))
  end
end
