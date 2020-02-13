# frozen_string_literal: true

module AwsIntegration
  class S3Accessor
    BUCKET_NAME = ->(application_name) { "deployqa-bucket-#{application_name}" }

    def initialize
      @s3_client = Aws::S3::Client.new
      @safe_call = Utils::SafeCall.new(exceptions: [StandardError])
    end

    def create_bucket(application_name)
      @safe_call.safely_with_result do
        @s3_client.create_bucket(bucket: BUCKET_NAME.call(application_name))
        BUCKET_NAME.call(application_name)
      end
    end

    def delete_bucket(application_name)
      @safe_call.safely_with_result do
        name = BUCKET_NAME.call(application_name)
        Aws::S3::Bucket.new(name, client: @s3_client).clear!
        @s3_client.delete_bucket(bucket: name)
        name
      end
    end
  end
end
