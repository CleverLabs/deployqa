# frozen_string_literal: true

class RedisKeys
  def instance_last_access_time(application_name)
    "deployqa.robad.access_count.instance_last_access_time.#{application_name}"
  end
end
