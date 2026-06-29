-- Migration 0096: PR-AIG-2 — Audit Events, Performance Metrics, Thresholds, Queues
CREATE TABLE IF NOT EXISTS ai_agent_audit_events (
    id TEXT PRIMARY KEY NOT NULL, unternehmen_id TEXT NOT NULL,
    agent_id TEXT NOT NULL, event_type TEXT NOT NULL,
    event_description TEXT NOT NULL, affected_subject_type TEXT,
    affected_subject_id TEXT, event_data TEXT,
    occurred_am TEXT NOT NULL DEFAULT (datetime('now')),
    erstellt_am TEXT NOT NULL DEFAULT (datetime('now'))
);
CREATE INDEX IF NOT EXISTS idx_ai_agent_audit_agent ON ai_agent_audit_events(agent_id);

CREATE TABLE IF NOT EXISTS ai_agent_performance_metrics (
    id TEXT PRIMARY KEY NOT NULL, unternehmen_id TEXT NOT NULL,
    agent_id TEXT NOT NULL, period_start TEXT NOT NULL, period_end TEXT NOT NULL,
    total_recommendations INTEGER DEFAULT 0,
    accepted INTEGER DEFAULT 0, rejected INTEGER DEFAULT 0,
    modified INTEGER DEFAULT 0, escalated INTEGER DEFAULT 0,
    false_positives INTEGER DEFAULT 0, false_negatives INTEGER DEFAULT 0,
    avg_review_time_hours REAL, financial_impact REAL,
    schedule_impact_days REAL, safety_impact_count INTEGER DEFAULT 0,
    acceptance_rate REAL, computed_am TEXT NOT NULL DEFAULT (datetime('now')),
    erstellt_am TEXT NOT NULL DEFAULT (datetime('now'))
);
CREATE INDEX IF NOT EXISTS idx_ai_perf_metrics_agent ON ai_agent_performance_metrics(agent_id);

CREATE TABLE IF NOT EXISTS ai_agent_review_thresholds (
    id TEXT PRIMARY KEY NOT NULL, unternehmen_id TEXT NOT NULL,
    agent_id TEXT, control_room TEXT,
    threshold_type TEXT NOT NULL, threshold_value REAL NOT NULL DEFAULT 0,
    action TEXT NOT NULL DEFAULT 'flag_for_review',
    is_active INTEGER NOT NULL DEFAULT 1,
    erstellt_am TEXT NOT NULL DEFAULT (datetime('now'))
);
CREATE INDEX IF NOT EXISTS idx_ai_review_thresholds_agent ON ai_agent_review_thresholds(agent_id);

CREATE TABLE IF NOT EXISTS ai_agent_review_queues (
    id TEXT PRIMARY KEY NOT NULL, unternehmen_id TEXT NOT NULL,
    recommendation_id TEXT NOT NULL, assigned_to TEXT,
    queue_status TEXT NOT NULL DEFAULT 'pending',
    priority TEXT DEFAULT 'normal', due_am TEXT,
    reviewed_am TEXT, erstellt_am TEXT NOT NULL DEFAULT (datetime('now'))
);
CREATE INDEX IF NOT EXISTS idx_ai_review_queues_status ON ai_agent_review_queues(queue_status);

CREATE TABLE IF NOT EXISTS aig_reviews (
    id TEXT PRIMARY KEY NOT NULL, unternehmen_id TEXT NOT NULL, project_id TEXT,
    reviewed_by TEXT NOT NULL, rolle TEXT NOT NULL DEFAULT 'ai_governance_lead',
    decision TEXT NOT NULL DEFAULT 'no_action', comments TEXT,
    reviewed_am TEXT NOT NULL DEFAULT (datetime('now')),
    erstellt_am TEXT NOT NULL DEFAULT (datetime('now'))
);
