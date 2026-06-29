-- Migration 0097: PR-PLN-1 — Activity Register, CPM Dependencies, Baselines
CREATE TABLE IF NOT EXISTS project_activities (
    id SERIAL PRIMARY KEY, unternehmen_id TEXT NOT NULL, project_id TEXT NOT NULL,
    wbs_code TEXT, activity_code TEXT NOT NULL, activity_name TEXT NOT NULL,
    description TEXT, activity_type TEXT DEFAULT 'construction',
    planned_start TEXT, planned_end TEXT, actual_start TEXT, actual_end TEXT,
    duration_days DOUBLE PRECISION, planned_pct DOUBLE PRECISION DEFAULT 0, actual_pct DOUBLE PRECISION DEFAULT 0,
    early_start DOUBLE PRECISION, early_finish DOUBLE PRECISION, late_start DOUBLE PRECISION, late_finish DOUBLE PRECISION,
    total_float DOUBLE PRECISION, is_critical INTEGER NOT NULL DEFAULT 0,
    status TEXT NOT NULL DEFAULT 'not_started', parent_id TEXT,
    boq_item_id TEXT, assigned_to TEXT,
    erstellt_am TEXT NOT NULL DEFAULT (NOW()), aktualisiert_am TEXT NOT NULL DEFAULT (NOW())
);
CREATE INDEX IF NOT EXISTS idx_project_activities_project ON project_activities(project_id);
CREATE INDEX IF NOT EXISTS idx_project_activities_wbs ON project_activities(wbs_code);
CREATE INDEX IF NOT EXISTS idx_project_activities_status ON project_activities(status);

CREATE TABLE IF NOT EXISTS activity_dependencies (
    id SERIAL PRIMARY KEY, predecessor_id TEXT NOT NULL, successor_id TEXT NOT NULL,
    dependency_type TEXT NOT NULL DEFAULT 'FS', lag_days DOUBLE PRECISION DEFAULT 0,
    is_active INTEGER NOT NULL DEFAULT 1,
    erstellt_am TEXT NOT NULL DEFAULT (NOW())
);
CREATE INDEX IF NOT EXISTS idx_activity_deps_pred ON activity_dependencies(predecessor_id);
CREATE INDEX IF NOT EXISTS idx_activity_deps_succ ON activity_dependencies(successor_id);

CREATE TABLE IF NOT EXISTS project_baselines (
    id SERIAL PRIMARY KEY, unternehmen_id TEXT NOT NULL, project_id TEXT NOT NULL,
    baseline_name TEXT NOT NULL, baseline_type TEXT NOT NULL DEFAULT 'schedule',
    version INTEGER NOT NULL DEFAULT 1, baseline_date TEXT NOT NULL,
    approved_by TEXT, approved_am TEXT,
    is_current INTEGER NOT NULL DEFAULT 0, notes TEXT,
    erstellt_am TEXT NOT NULL DEFAULT (NOW())
);
CREATE INDEX IF NOT EXISTS idx_project_baselines_project ON project_baselines(project_id);

CREATE TABLE IF NOT EXISTS schedule_baseline_versions (
    id SERIAL PRIMARY KEY, baseline_id TEXT NOT NULL,
    activity_id TEXT NOT NULL, planned_start TEXT NOT NULL, planned_end TEXT NOT NULL,
    duration_days DOUBLE PRECISION, planned_pct DOUBLE PRECISION DEFAULT 0,
    erstellt_am TEXT NOT NULL DEFAULT (NOW())
);
CREATE INDEX IF NOT EXISTS idx_schedule_baseline_versions_baseline ON schedule_baseline_versions(baseline_id);

CREATE TABLE IF NOT EXISTS pln_agent_recommendations (
    id SERIAL PRIMARY KEY, unternehmen_id TEXT NOT NULL, agent_id TEXT,
    project_id TEXT NOT NULL, activity_id TEXT,
    issue TEXT NOT NULL, evidence TEXT,
    risk_level TEXT NOT NULL DEFAULT 'medium', recommended_action TEXT NOT NULL,
    owner TEXT, status TEXT NOT NULL DEFAULT 'pending_review',
    detected_am TEXT NOT NULL DEFAULT (NOW()), reviewed_am TEXT,
    erstellt_am TEXT NOT NULL DEFAULT (NOW())
);
CREATE INDEX IF NOT EXISTS idx_pln_agent_recs_project ON pln_agent_recommendations(project_id);
