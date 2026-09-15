require_relative "boot"

require "rails"
require "active_model/railtie"
require "active_job/railtie"
require "active_record/railtie"
require "action_controller/railtie"
require "action_cable/engine"

Bundler.require(*Rails.groups)

module ChatServer
  class Application < Rails::Application
    config.load_defaults 8.0
    config.api_only = true
    config.time_zone = "Asia/Ho_Chi_Minh"
    config.active_record.schema_format = :ruby
    config.middleware.use ActionDispatch::Cookies
    config.middleware.use ActionDispatch::Session::CookieStore
  end
end
