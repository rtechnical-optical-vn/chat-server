module AdminAuthenticatable
  extend ActiveSupport::Concern

  private

  def require_admin_key!
    expected = ENV["CHAT_ADMIN_API_KEY"]
    if expected.blank?
      render_json({ error: "CHAT_ADMIN_API_KEY is not configured" }, http_status: :service_unavailable)
      return false
    end

    provided = request.headers["x-chat-admin-key"].to_s
    unless provided.present? && ActiveSupport::SecurityUtils.secure_compare(provided, expected)
      render_json({ error: "Unauthorized" }, http_status: :unauthorized)
      return false
    end

    true
  end
end
