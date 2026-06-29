-- Migration 0098: PR-PLN-2 — Lookahead, Readiness, Blockers, Reviews
CREATE TABLE IF NOT EXISTS lookahead_plans (
    id SERIAL PRIMARY KEY, unternehmen_id TEXT NOT NULL, project_id TEXT NOT NULL,
    lookahead_weeks INTEGER NOT NULL, generated_am TEXT NOT NULL DEFAULT (NOW()),
    start_date TEXT NOT NULL, end_date TEXT NOT NULL,
    is_current INTEGER NOT NULL DEFAULT 0,
    erstellt_am TEXT NOT NULL DEFAULT (NOW())
);
CREATE INDEX IF NOT EXISTS idx_lookahead_plans_project ON lookahead_plans(project_id);

CREATE TABLE IF NOT EXISTS lookahead_readiness (
    id SERIAL PRIMARY KEY, lookahead_id TEXT NOT NULL,
    activity_id TEXT NOT NULL,
    readiness_materials INTEGER NOT NULL DEFAULT 0,
    readiness_equipment INTEGER NOT NULL DEFAULT 0,
    readiness_labour INTEGER NOT NULL DEFAULT 0,
    readiness_drawings INTEGER NOT NULL DEFAULT 0,
    readiness_permits INTEGER NOT NULL DEFAULT 0,
    readiness_rfi INTEGER NOT NULL DEFAULT 0,
    readiness_method INTEGER NOT NULL DEFAULT 0,
    readiness_qa_hse INTEGER NOT NULL DEFAULT 0,
    readiness_subcontractor INTEGER NOT NULL DEFAULT 0,
    readiness_overall INTEGER NOT NULL DEFAULT 0,
    lead_time_days DOUBLE PRECISION,
    verified_by TEXT, verified_am TEXT,
    erstellt_am TEXT NOT NULL DEFAULT (NOW())
);
CREATE INDEX IF NOT EXISTS idx_lookahead_readiness_plan ON lookahead_readiness(lookahead_id);

CREATE TABLE IF NOT EXISTS schedule_blockers (
    id SERIAL PRIMARY KEY, unternehmen_id TEXT NOT NULL, project_id TEXT NOT NULL,
    activity_id TEXT NOT NULL, blocker_type TEXT NOT NULL,
    description TEXT NOT NULL, severity TEXT NOT NULL DEFAULT 'high',
    raised_by TEXT NOT NULL, raised_am TEXT NOT NULL DEFAULT (NOW()),
    resolution TEXT, resolved_by TEXT, resolved_am TEXT,
    cascading_predecessors TEXT, status TEXT NOT NULL DEFAULT 'active',
    erstellt_am TEXT NOT NULL DEFAULT (NOW()), aktualisiert_am TEXT NOT NULL DEFAULT (NOW())
);
CREATE INDEX IF NOT EXISTS idx_schedule_blockers_project ON schedule_blockers(project_id);
CREATE INDEX IF NOT EXISTS idx_schedule_blockers_activity ON schedule_blockers(activity_id);

CREATE TABLE IF NOT EXISTS planning_reviews (
    id SERIAL PRIMARY KEY, unternehmen_id TEXT NOT NULL, project_id TEXT,
    reviewed_by TEXT NOT NULL, rolle TEXT NOT NULL DEFAULT 'planner',
    review_type TEXT NOT NULL DEFAULT 'lookahead', decision TEXT NOT NULL DEFAULT 'no_action',
    comments TEXT, reviewed_am TEXT NOT NULL DEFAULT (NOW()),
    erstellt_am TEXT NOT NULL DEFAULT (NOW())
);
CREATE INDEX IF NOT EXISTS idx_planning_reviews_project ON planning_reviews(project_id);

CREATE TABLE IF NOT EXISTS pln_reviews (
    id SERIAL PRIMARY KEY, unternehmen_id TEXT NOT NULL, project_id TEXT,
    reviewed_by TEXT NOT NULL, rolle TEXT NOT NULL DEFAULT 'project_manager',
    decision TEXT NOT NULL DEFAULT 'no_action', comments TEXT,
    reviewed_am TEXT NOT NULL DEFAULT (NOW()),
    erstellt_am TEXT NOT NULL DEFAULT (NOW())
);
