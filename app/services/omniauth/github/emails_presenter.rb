# frozen_string_literal: true

module Omniauth
  module Github
    class EmailsPresenter
      def initialize(emails)
        @emails = emails
      end

      def primary_email
        primary_email = @emails.find { |email_object| email_object[:primary] == true }

        return @emails.first[:email] unless primary_email

        primary_email[:email]
      end
    end
  end
end
