# frozen_string_literal: true

module Routes
  class LoggedUserConstraint
    def initialize(policy_class)
      @policy_class = policy_class
    end

    def matches?(request)
      return if request.session[:user_id].blank?

      user = User.find(request.session[:user_id])
      @policy_class.new(user, nil).show?
    end
  end
end
