require "active_support/core_ext/integer/time"

Rails.application.configure do
  config.enable_reloading = true
  config.eager_load = false
  config.consider_all_requests_local = true
  config.server_timing = true
  config.action_cable.disable_request_forgery_protection = true
  config.action_cable.allowed_request_origins = [
    /http:\/\/localhost:\d+/,
    /http:\/\/127\.0\.0\.1:\d+/,
    /https:\/\/.*\.rtechnical\.com\.vn/,
    /https:\/\/rtechnical\.com\.vn/
  ]
  config.active_record.migration_error = :page_load
  config.active_record.verbose_query_logs = true
  config.active_support.deprecation = :log
end
