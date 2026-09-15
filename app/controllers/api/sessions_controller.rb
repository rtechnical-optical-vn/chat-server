module Api
  class SessionsController < ApplicationController
    DEFAULT_WELCOME =
      "Xin chào! R Technical đã nhận tin nhắn của bạn. Đội ngũ sẽ phản hồi trong thời gian sớm nhất."

    def create
      payload = request.request_parameters
      welcome_content = payload["welcomeMessage"].to_s.strip
      welcome_content = DEFAULT_WELCOME if welcome_content.blank?

      session = ChatSession.create!(
        id: SecureRandom.uuid,
        visitorToken: SecureRandom.uuid,
        visitorName: payload["visitorName"].to_s.strip.presence,
        visitorEmail: payload["visitorEmail"].to_s.strip.presence,
        visitorPhone: payload["visitorPhone"].to_s.strip.presence,
        pageUrl: payload["pageUrl"].to_s.strip.presence,
        locale: payload["locale"].to_s.strip.presence,
        updatedAt: Time.current
      )

      welcome = session.messages.create!(
        id: SecureRandom.uuid,
        sender: "SYSTEM",
        content: welcome_content
      )
      session.touch_last_message!(welcome.content, at: welcome.createdAt)

      render_json(
        {
          session: session.as_api_json.slice(:id, :visitorToken, :visitorName, :status),
          messages: [welcome.as_api_json]
        },
        http_status: :created
      )
    rescue StandardError => e
      Rails.logger.error("Create session failed: #{e.message}")
      render_json({ error: "Failed to create chat session" }, http_status: :internal_server_error)
    end

    def messages
      session = find_visitor_session
      return unless session

      messages = session.messages.chronological.limit(200)
      render_json(session: session.as_api_json, messages: messages.map(&:as_api_json))
    end

    def create_message
      session = find_visitor_session
      return unless session

      text = request.request_parameters["content"].to_s.strip
      if text.blank?
        render_json({ error: "Message content is required" }, http_status: :bad_request)
        return
      end

      unless session.open?
        render_json({ error: "Session is closed" }, http_status: :bad_request)
        return
      end

      message = session.messages.create!(
        id: SecureRandom.uuid,
        sender: "VISITOR",
        content: text
      )
      session.touch_last_message!(text, at: message.createdAt)

      if request.request_parameters["visitorName"].present? && session.visitorName.blank?
        session.update!(visitorName: request.request_parameters["visitorName"].to_s.strip)
      end

      Chat::Broadcaster.broadcast_new_message(session.id, message)
      render_json({ message: message.as_api_json }, http_status: :created)
    end

    private

    def find_visitor_session
      token = params[:visitorToken].presence || request.request_parameters["visitorToken"]
      session = ChatSession.find_by(id: params[:session_id], visitorToken: token)
      render_json({ error: "Session not found" }, http_status: :not_found) unless session
      session
    end
  end
end
