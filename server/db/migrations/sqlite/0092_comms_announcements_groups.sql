-- Migration 0092: PR-COMMS-2 — Announcements, Groups, Contacts, Reviews
CREATE TABLE IF NOT EXISTS project_announcements (
    id TEXT PRIMARY KEY NOT NULL, unternehmen_id TEXT NOT NULL, project_id TEXT NOT NULL,
    title TEXT NOT NULL, body TEXT NOT NULL, priority TEXT DEFAULT 'normal',
    published_by TEXT NOT NULL, published_am TEXT NOT NULL DEFAULT (datetime('now')),
    expires_am TEXT, is_active INTEGER NOT NULL DEFAULT 1,
    erstellt_am TEXT NOT NULL DEFAULT (datetime('now'))
);
CREATE INDEX IF NOT EXISTS idx_project_announcements_project ON project_announcements(project_id);

CREATE TABLE IF NOT EXISTS communication_groups (
    id TEXT PRIMARY KEY NOT NULL, unternehmen_id TEXT NOT NULL, project_id TEXT,
    group_name TEXT NOT NULL, description TEXT,
    created_by TEXT NOT NULL, is_active INTEGER NOT NULL DEFAULT 1,
    erstellt_am TEXT NOT NULL DEFAULT (datetime('now'))
);
CREATE INDEX IF NOT EXISTS idx_communication_groups_project ON communication_groups(project_id);

CREATE TABLE IF NOT EXISTS communication_group_members (
    id TEXT PRIMARY KEY NOT NULL, group_id TEXT NOT NULL,
    user_id TEXT NOT NULL, rolle TEXT DEFAULT 'member',
    added_by TEXT NOT NULL, added_am TEXT NOT NULL DEFAULT (datetime('now')),
    erstellt_am TEXT NOT NULL DEFAULT (datetime('now'))
);
CREATE INDEX IF NOT EXISTS idx_comm_group_members_group ON communication_group_members(group_id);

CREATE TABLE IF NOT EXISTS contact_lists (
    id TEXT PRIMARY KEY NOT NULL, unternehmen_id TEXT NOT NULL, project_id TEXT,
    contact_name TEXT NOT NULL, contact_role TEXT, email TEXT, phone TEXT,
    organization TEXT, notes TEXT,
    erstellt_am TEXT NOT NULL DEFAULT (datetime('now'))
);
CREATE INDEX IF NOT EXISTS idx_contact_lists_project ON contact_lists(project_id);

CREATE TABLE IF NOT EXISTS comms_reviews (
    id TEXT PRIMARY KEY NOT NULL, unternehmen_id TEXT NOT NULL, project_id TEXT,
    reviewed_by TEXT NOT NULL, rolle TEXT NOT NULL DEFAULT 'project_manager',
    decision TEXT NOT NULL DEFAULT 'no_action', comments TEXT,
    reviewed_am TEXT NOT NULL DEFAULT (datetime('now')),
    erstellt_am TEXT NOT NULL DEFAULT (datetime('now'))
);
