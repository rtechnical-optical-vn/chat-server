class CreateChatTables < ActiveRecord::Migration[8.0]
  def up
    return if table_exists?("ChatSession")

    execute <<~SQL
      CREATE TYPE "ChatSessionStatus" AS ENUM ('OPEN', 'CLOSED');
    SQL
    execute <<~SQL
      CREATE TYPE "MessageSender" AS ENUM ('VISITOR', 'STAFF', 'SYSTEM');
    SQL

    execute <<~SQL
      CREATE TABLE "ChatSession" (
          "id" UUID NOT NULL,
          "visitorToken" UUID NOT NULL,
          "visitorName" TEXT,
          "visitorEmail" TEXT,
          "visitorPhone" TEXT,
          "pageUrl" TEXT,
          "locale" TEXT,
          "status" "ChatSessionStatus" NOT NULL DEFAULT 'OPEN',
          "lastMessage" TEXT,
          "lastMessageAt" TIMESTAMPTZ(6),
          "createdAt" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
          "updatedAt" TIMESTAMPTZ(6) NOT NULL,
          CONSTRAINT "ChatSession_pkey" PRIMARY KEY ("id")
      );
    SQL

    execute <<~SQL
      CREATE TABLE "ChatMessage" (
          "id" UUID NOT NULL,
          "sessionId" UUID NOT NULL,
          "sender" "MessageSender" NOT NULL,
          "staffName" TEXT,
          "content" TEXT NOT NULL,
          "createdAt" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
          CONSTRAINT "ChatMessage_pkey" PRIMARY KEY ("id")
      );
    SQL

    execute <<~SQL
      CREATE UNIQUE INDEX "ChatSession_visitorToken_key" ON "ChatSession"("visitorToken");
      CREATE INDEX "ChatSession_status_lastMessageAt_idx" ON "ChatSession"("status", "lastMessageAt" DESC);
      CREATE INDEX "ChatSession_createdAt_idx" ON "ChatSession"("createdAt" DESC);
      CREATE INDEX "ChatMessage_sessionId_createdAt_idx" ON "ChatMessage"("sessionId", "createdAt");
      ALTER TABLE "ChatMessage" ADD CONSTRAINT "ChatMessage_sessionId_fkey"
        FOREIGN KEY ("sessionId") REFERENCES "ChatSession"("id") ON DELETE CASCADE ON UPDATE CASCADE;
    SQL
  end

  def down
    drop_table "ChatMessage", if_exists: true
    drop_table "ChatSession", if_exists: true
    execute 'DROP TYPE IF EXISTS "MessageSender"'
    execute 'DROP TYPE IF EXISTS "ChatSessionStatus"'
  end
end
