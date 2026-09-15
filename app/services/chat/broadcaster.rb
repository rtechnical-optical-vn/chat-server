module Chat
  class Broadcaster
    def self.session_stream(session_id)
      "chat_session_#{session_id}"
    end

    def self.broadcast_new_message(session_id, message)
      ActionCable.server.broadcast(
        session_stream(session_id),
        {
          type: "new_message",
          sessionId: session_id,
          message: message.as_api_json
        }
      )
    end
  end
end
