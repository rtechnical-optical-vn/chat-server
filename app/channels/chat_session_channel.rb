class ChatSessionChannel < ApplicationCable::Channel
  def subscribed
    @session = ChatSession.find_by(
      id: params[:session_id],
      visitorToken: params[:visitor_token]
    )

    if @session
      stream_from Chat::Broadcaster.session_stream(@session.id)
      transmit(
        type: "message_history",
        sessionId: @session.id,
        messages: @session.messages.chronological.limit(200).map(&:as_api_json)
      )
    else
      reject
    end
  end

  def send_message(data)
    return unless @session&.open?

    text = data["content"].to_s.strip
    return if text.blank?

    message = @session.messages.create!(
      id: SecureRandom.uuid,
      sender: "VISITOR",
      content: text
    )
    @session.touch_last_message!(text, at: message.createdAt)

    Chat::Broadcaster.broadcast_new_message(@session.id, message)
  end
end
