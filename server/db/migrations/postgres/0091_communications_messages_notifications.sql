-- Migration 0091: PR-COMMS-1 — Messages, Notifications, Templates
CREATE TABLE IF NOT EXISTS platform_messages (
    id SERIAL PRIMARY KEY, unternehmen_id TEXT NOT NULL, project_id TEXT,
    sender_id TEXT NOT NULL, subject TEXT, body TEXT NOT NULL,
    priority TEXT DEFAULT 'normal', is_read INTEGER NOT NULL DEFAULT 0,
    read_am TEXT, recipients TEXT, parent_message_id TEXT,
    erstellt_am TEXT NOT NULL DEFAULT (NOW())
);
CREATE INDEX IF NOT EXISTS idx_platform_messages_project ON platform_messages(project_id);
CREATE INDEX IF NOT EXISTS idx_platform_messages_sender ON platform_messages(sender_id);

CREATE TABLE IF NOT EXISTS notification_channels (
    id SERIAL PRIMARY KEY, unternehmen_id TEXT NOT NULL,
    channel_type TEXT NOT NULL, channel_label TEXT NOT NULL,
    config TEXT, is_active INTEGER NOT NULL DEFAULT 1,
    erstellt_am TEXT NOT NULL DEFAULT (NOW())
);
CREATE INDEX IF NOT EXISTS idx_notification_channels_type ON notification_channels(channel_type);

CREATE TABLE IF NOT EXISTS notification_templates (
    id SERIAL PRIMARY KEY, unternehmen_id TEXT NOT NULL,
    template_code TEXT NOT NULL, template_name TEXT NOT NULL,
    channel_type TEXT NOT NULL, subject_template TEXT,
    body_template TEXT NOT NULL, variables TEXT,
    is_active INTEGER NOT NULL DEFAULT 1,
    erstellt_am TEXT NOT NULL DEFAULT (NOW())
);
CREATE INDEX IF NOT EXISTS idx_notification_templates_code ON notification_templates(template_code);

CREATE TABLE IF NOT EXISTS notification_logs (
    id SERIAL PRIMARY KEY, unternehmen_id TEXT NOT NULL,
    template_id TEXT, channel_type TEXT NOT NULL,
    recipient TEXT NOT NULL, subject TEXT, body TEXT NOT NULL,
    status TEXT NOT NULL DEFAULT 'sent', error_message TEXT,
    sent_am TEXT NOT NULL DEFAULT (NOW()),
    erstellt_am TEXT NOT NULL DEFAULT (NOW())
);
CREATE INDEX IF NOT EXISTS idx_notification_logs_recipient ON notification_logs(recipient);
CREATE INDEX IF NOT EXISTS idx_notification_logs_status ON notification_logs(status);

CREATE TABLE IF NOT EXISTS comms_agent_recommendations (
    id SERIAL PRIMARY KEY, unternehmen_id TEXT NOT NULL, agent_id TEXT,
    project_id TEXT, issue TEXT NOT NULL, evidence TEXT,
    risk_level TEXT NOT NULL DEFAULT 'low', recommended_action TEXT NOT NULL,
    owner TEXT, status TEXT NOT NULL DEFAULT 'pending_review',
    detected_am TEXT NOT NULL DEFAULT (NOW()), reviewed_am TEXT,
    erstellt_am TEXT NOT NULL DEFAULT (NOW())
);
CREATE INDEX IF NOT EXISTS idx_comms_agent_recs_status ON comms_agent_recommendations(status);
