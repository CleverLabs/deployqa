# frozen_string_literal: true

module ServerAccess
  module HerokuHelpers
    class SafeCall
      RESULT_TRANSFORMATION = {
        ReturnValue => ->(result) { result },
        Array => ->(result) { ReturnValue.ok(Hash[(0...result.size).zip result]) }
      }.freeze

      DEFAULT_RESULT_TRANSFORMATION = ->(result) { ReturnValue.ok(result) }
      MAX_NUMBER_OF_TRIES = 3
      TIME_TO_SLEEP_BEFORE_RETRY = 3

      def safely(&block)
        result = safe_call(&block)
        return ReturnValue.ok if result.ok?

        result
      end

      def safely_with_result(&block)
        safe_call(&block)
      end

      private

      def safe_call(&block)
        with_repeat do
          result = block.call
          RESULT_TRANSFORMATION.fetch(result.class, DEFAULT_RESULT_TRANSFORMATION).call(result)
        end
      rescue Excon::Error::UnprocessableEntity, Excon::Error::NotFound => error
        ReturnValue.error(errors: error.response.data[:body])
      end

      def with_repeat(tries: MAX_NUMBER_OF_TRIES)
        try_counter = 0
        begin
          yield try_counter
        rescue Excon::Error::UnprocessableEntity, Excon::Error::NotFound
          if (try_counter += 1) <= tries
            sleep TIME_TO_SLEEP_BEFORE_RETRY
            retry
          end

          raise
        end
      end
    end
  end
end
