# frozen_string_literal: true

user = User.seed(:full_name) do |seed|
  seed.full_name = "System"
  seed.system_role = UserConstants::SystemRoles::AUTOMATIC_SYSTEM
end.first

UserReference.seed(:full_name) do |seed|
  seed.full_name = "System"
  seed.auth_provider = OmniauthConstants::NO_PROVIDER
  seed.auth_uid = SecureRandom.uuid
  seed.user_id = user.id
end
