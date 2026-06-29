-- Migration 0095: PR-AIG-1 — Agent Registry + Recommendation Log
CREATE TABLE IF NOT EXISTS ai_agents (
    id TEXT PRIMARY KEY NOT NULL, unternehmen_id TEXT NOT NULL,
    agent_code TEXT NOT NULL, agent_name TEXT NOT NULL,
    control_room TEXT NOT NULL, description TEXT,
    capabilities TEXT, risk_category TEXT NOT NULL DEFAULT 'medium',
    requires_human_approval INTEGER NOT NULL DEFAULT 1,
    is_active INTEGER NOT NULL DEFAULT 1,
    erstellt_am TEXT NOT NULL DEFAULT (datetime('now')), aktualisiert_am TEXT NOT NULL DEFAULT (datetime('now'))
);
CREATE INDEX IF NOT EXISTS idx_ai_agents_control_room ON ai_agents(control_room);
CREATE INDEX IF NOT EXISTS idx_ai_agents_code ON ai_agents(agent_code);

CREATE TABLE IF NOT EXISTS ai_agent_versions (
    id TEXT PRIMARY KEY NOT NULL, agent_id TEXT NOT NULL,
    version TEXT NOT NULL, changelog TEXT,
    config_snapshot TEXT, deployed_by TEXT, deployed_am TEXT,
    status TEXT NOT NULL DEFAULT 'active',
    erstellt_am TEXT NOT NULL DEFAULT (datetime('now'))
);
CREATE INDEX IF NOT EXISTS idx_ai_agent_versions_agent ON ai_agent_versions(agent_id);

CREATE TABLE IF NOT EXISTS ai_agent_recommendations (
    id TEXT PRIMARY KEY NOT NULL, unternehmen_id TEXT NOT NULL,
    agent_id TEXT NOT NULL, agent_version_id TEXT,
    project_id TEXT, subject_type TEXT NOT NULL,
    subject_id TEXT NOT NULL, recommendation TEXT NOT NULL,
    evidence_summary TEXT, confidence REAL,
    risk_level TEXT NOT NULL DEFAULT 'medium',
    requires_human_approval INTEGER NOT NULL DEFAULT 1,
    created_am TEXT NOT NULL DEFAULT (datetime('now')),
    erstellt_am TEXT NOT NULL DEFAULT (datetime('now'))
);
CREATE INDEX IF NOT EXISTS idx_ai_agent_recs_agent ON ai_agent_recommendations(agent_id);
CREATE INDEX IF NOT EXISTS idx_ai_agent_recs_subject ON ai_agent_recommendations(subject_type, subject_id);

CREATE TABLE IF NOT EXISTS ai_agent_evidence_links (
    id TEXT PRIMARY KEY NOT NULL, recommendation_id TEXT NOT NULL,
    evidence_type TEXT NOT NULL, evidence_ref TEXT NOT NULL,
    evidence_summary TEXT,
    erstellt_am TEXT NOT NULL DEFAULT (datetime('now'))
);
CREATE INDEX IF NOT EXISTS idx_ai_agent_evidence_rec ON ai_agent_evidence_links(recommendation_id);

CREATE TABLE IF NOT EXISTS ai_agent_reviews (
    id TEXT PRIMARY KEY NOT NULL, recommendation_id TEXT NOT NULL,
    reviewed_by TEXT NOT NULL, reviewer_role TEXT NOT NULL,
    decision TEXT NOT NULL DEFAULT 'pending',
    decision_reason TEXT, reviewed_am TEXT NOT NULL DEFAULT (datetime('now')),
    erstellt_am TEXT NOT NULL DEFAULT (datetime('now'))
);
CREATE INDEX IF NOT EXISTS idx_ai_agent_reviews_rec ON ai_agent_reviews(recommendation_id);
