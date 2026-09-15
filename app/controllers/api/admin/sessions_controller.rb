module Api
  module Admin
    class SessionsController < ApplicationController
      include AdminAuthenticatable

      before_action :authenticate_admin!

      def index
        status_filter = params[:status]
        scope =
          case status_filter
          when "CLOSED" then ChatSession.where(status: "CLOSED")
          when "ALL" then ChatSession.all
          else ChatSession.open_sessions
          end

        sessions = scope.recent_first.limit(100).map do |session|
          session.as_api_json.merge(
            _count: { messages: session.messages.count }
          )
        end

        render_json({ sessions: sessions })
      rescue StandardError => e
        Rails.logger.error("Admin list sessions failed: #{e.message}")
        render_json({ error: "Failed to list sessions" }, http_status: :internal_server_error)
      end

      def messages
        session = ChatSession.find_by(id: params[:session_id])
        return render_json({ error: "Session not found" }, http_status: :not_found) unless session

        messages = session.messages.chronological.limit(500)
        render_json(session: session.as_api_json, messages: messages.map(&:as_api_json))
      end

      def create_message
        session = ChatSession.find_by(id: params[:session_id])
        return render_json({ error: "Session not found" }, http_status: :not_found) unless session

        payload = request.request_parameters
        text = payload["content"].to_s.strip
        if text.blank?
          render_json({ error: "Message content is required" }, http_status: :bad_request)
          return
        end

        message = session.messages.create!(
          id: SecureRandom.uuid,
          sender: "STAFF",
          staffName: payload["staffName"].to_s.strip.presence || "R Technical",
          content: text
        )
        session.touch_last_message!(text, at: message.createdAt)
        Chat::Broadcaster.broadcast_new_message(session.id, message)

        render_json({ message: message.as_api_json }, http_status: :created)
      end

      def update
        session = ChatSession.find_by(id: params[:session_id])
        return render_json({ error: "Session not found" }, http_status: :not_found) unless session

        status = request.request_parameters["status"]
        unless %w[OPEN CLOSED].include?(status)
          render_json({ error: "status must be OPEN or CLOSED" }, http_status: :bad_request)
          return
        end

        session.update!(status: status, updatedAt: Time.current)
        render_json({ session: session.as_api_json })
      end

      private

      def authenticate_admin!
        require_admin_key!
      end
    end
  end
end
