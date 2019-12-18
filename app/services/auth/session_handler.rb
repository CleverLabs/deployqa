# frozen_string_literal: true

module Auth
  class SessionHandler
    def initialize(session)
      @session = session
    end

    def set!(params)
      @session.merge!(params)
    end

    def clear!
      @session.clear
    end
  end
end
