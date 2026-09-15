class ChatMessage < ApplicationRecord
  self.table_name = "ChatMessage"
  self.record_timestamps = false

  belongs_to :session,
             class_name: "ChatSession",
             foreign_key: "sessionId",
             inverse_of: :messages

  SENDERS = %w[VISITOR STAFF SYSTEM].freeze

  validates :sender, inclusion: { in: SENDERS }
  validates :content, presence: true

  before_create { self.createdAt ||= Time.current }

  scope :chronological, -> { order(createdAt: :asc) }

  def as_api_json
    {
      id: id,
      sessionId: sessionId,
      sender: sender,
      staffName: staffName,
      content: content,
      createdAt: createdAt&.iso8601(3)
    }
  end
end
