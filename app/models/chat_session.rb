class ChatSession < ApplicationRecord
  self.table_name = "ChatSession"
  self.record_timestamps = false

  has_many :messages,
           class_name: "ChatMessage",
           foreign_key: "sessionId",
           inverse_of: :session,
           dependent: :destroy

  STATUSES = %w[OPEN CLOSED].freeze

  validates :status, inclusion: { in: STATUSES }

  before_create :stamp_create_times
  before_update { self.updatedAt = Time.current }

  scope :open_sessions, -> { where(status: "OPEN") }
  scope :recent_first, -> { order(lastMessageAt: :desc, createdAt: :desc) }

  def open?
    status == "OPEN"
  end

  def touch_last_message!(content, at: Time.current)
    update!(lastMessage: content, lastMessageAt: at)
  end

  def stamp_create_times
    now = Time.current
    self.createdAt ||= now
    self.updatedAt ||= now
  end

  def as_api_json
    {
      id: id,
      visitorToken: visitorToken,
      visitorName: visitorName,
      visitorEmail: visitorEmail,
      visitorPhone: visitorPhone,
      status: status,
      lastMessage: lastMessage,
      lastMessageAt: lastMessageAt&.iso8601(3),
      createdAt: createdAt&.iso8601(3)
    }
  end
end
