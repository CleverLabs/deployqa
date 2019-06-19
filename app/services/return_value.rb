# frozen_string_literal: true

class ReturnValue
  include ShallowAttributes
  STATUSES = %i[ok error no_action].freeze

  attribute :object, Object
  attribute :status, String, present: true
  attribute :errors, Object

  delegate :ok?, :error?, :no_action?, to: :status

  alias _status= status=
  alias _errors= errors=

  def self.ok(object = nil)
    new(status: :ok, object: object)
  end

  def self.error(object: nil, errors: nil)
    new(status: :error, object: object, errors: errors)
  end

  def status=(value)
    raise ArgumentError, value unless value.in?(STATUSES)

    self._status = value.to_s.inquiry
  end

  def errors=(value)
    @errors = value.is_a?(::Hash) ? value : Array(value)
    @attributes[:errors] = @errors
  end
end
