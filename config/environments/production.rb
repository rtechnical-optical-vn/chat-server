require "active_support/core_ext/integer/time"

Rails.application.configure do
  config.enable_reloading = false
  config.eager_load = true
  config.consider_all_requests_local = false
  config.action_cable.disable_request_forgery_protection = true
  config.action_cable.allowed_request_origins = ENV.fetch("CORS_ORIGIN", "")
    .split(",")
    .map(&:strip)
    .reject(&:empty?)
    .map { |origin| origin == "*" ? origin : Regexp.new("\\A#{Regexp.escape(origin)}/?\\z") }
  config.log_tags = [:request_id]
  config.logger = ActiveSupport::TaggedLogging.logger($stdout)
  config.log_level = ENV.fetch("RAILS_LOG_LEVEL", "info")
  config.active_support.report_deprecations = false
  config.active_record.dump_schema_after_migration = false
end
