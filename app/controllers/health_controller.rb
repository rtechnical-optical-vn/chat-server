class HealthController < ApplicationController
  def show
    render_json(
      status: "ok",
      service: "rtechnical-chat-server",
      cable: "/cable",
      timestamp: Time.current.iso8601
    )
  end

  def index
    render_json(
      service: "R Technical Chat Server (Rails Action Cable)",
      health: "/health",
      cable: "/cable"
    )
  end
end
