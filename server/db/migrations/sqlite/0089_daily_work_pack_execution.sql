-- =============================================================================
-- Migration 0089: PR-DWE-1 — Work Pack + Execution Record Backbone
-- =============================================================================

CREATE TABLE IF NOT EXISTS daily_work_packs (
    id                  TEXT PRIMARY KEY NOT NULL,
    unternehmen_id      TEXT NOT NULL,
    project_id          TEXT NOT NULL,
    activity_id         TEXT,
    pack_number         TEXT,
    title               TEXT NOT NULL,
    description         TEXT,
    work_date           TEXT NOT NULL,
    shift               TEXT DEFAULT 'day',
    planned_output      TEXT,
    status              TEXT NOT NULL DEFAULT 'draft',
    readiness_materials    INTEGER NOT NULL DEFAULT 0,
    readiness_equipment    INTEGER NOT NULL DEFAULT 0,
    readiness_labour       INTEGER NOT NULL DEFAULT 0,
    readiness_drawings     INTEGER NOT NULL DEFAULT 0,
    readiness_permits      INTEGER NOT NULL DEFAULT 0,
    readiness_method       INTEGER NOT NULL DEFAULT 0,
    readiness_qa_hse       INTEGER NOT NULL DEFAULT 0,
    readiness_subcontractor INTEGER NOT NULL DEFAULT 0,
    readiness_overall      INTEGER NOT NULL DEFAULT 0,
    released_by         TEXT,
    released_am         TEXT,
    foreman_id          TEXT,
    notes               TEXT,
    erstellt_am         TEXT NOT NULL DEFAULT (datetime('now')),
    aktualisiert_am     TEXT NOT NULL DEFAULT (datetime('now'))
);

CREATE INDEX IF NOT EXISTS idx_daily_work_packs_project
    ON daily_work_packs(project_id);
CREATE INDEX IF NOT EXISTS idx_daily_work_packs_date
    ON daily_work_packs(work_date);
CREATE INDEX IF NOT EXISTS idx_daily_work_packs_status
    ON daily_work_packs(status);

CREATE TABLE IF NOT EXISTS work_pack_items (
    id                  TEXT PRIMARY KEY NOT NULL,
    work_pack_id        TEXT NOT NULL,
    boq_item_id         TEXT,
    description         TEXT NOT NULL,
    planned_quantity    REAL NOT NULL DEFAULT 0,
    unit                TEXT NOT NULL DEFAULT 'No.',
    crew_id             TEXT,
    equipment_id        TEXT,
    notes               TEXT,
    erstellt_am         TEXT NOT NULL DEFAULT (datetime('now'))
);

CREATE INDEX IF NOT EXISTS idx_work_pack_items_pack
    ON work_pack_items(work_pack_id);

CREATE TABLE IF NOT EXISTS daily_work_execution_records (
    id                  TEXT PRIMARY KEY NOT NULL,
    unternehmen_id      TEXT NOT NULL,
    project_id          TEXT NOT NULL,
    work_pack_id        TEXT NOT NULL,
    activity_id         TEXT,
    boq_item_id         TEXT,
    record_date         TEXT NOT NULL,
    description         TEXT NOT NULL,
    actual_quantity     REAL NOT NULL DEFAULT 0,
    unit                TEXT NOT NULL DEFAULT 'No.',
    planned_vs_actual   TEXT,
    crew_size           INTEGER DEFAULT 0,
    hours_worked        REAL DEFAULT 0,
    equipment_used      TEXT,
    materials_consumed  TEXT,
    weather_conditions  TEXT,
    delays_encountered  TEXT,
    hse_incidents       INTEGER DEFAULT 0,
    quality_issues      INTEGER DEFAULT 0,
    recorded_by         TEXT NOT NULL,
    foreman_id          TEXT,
    notes               TEXT,
    erstellt_am         TEXT NOT NULL DEFAULT (datetime('now'))
);

CREATE INDEX IF NOT EXISTS idx_daily_work_execution_pack
    ON daily_work_execution_records(work_pack_id);
CREATE INDEX IF NOT EXISTS idx_daily_work_execution_date
    ON daily_work_execution_records(record_date);
CREATE INDEX IF NOT EXISTS idx_daily_work_execution_project
    ON daily_work_execution_records(project_id);

CREATE TABLE IF NOT EXISTS work_execution_resources (
    id                  TEXT PRIMARY KEY NOT NULL,
    execution_record_id TEXT NOT NULL,
    resource_type       TEXT NOT NULL,
    resource_id         TEXT NOT NULL,
    quantity            REAL NOT NULL DEFAULT 0,
    unit                TEXT NOT NULL DEFAULT 'No.',
    hours_used          REAL,
    notes               TEXT,
    erstellt_am         TEXT NOT NULL DEFAULT (datetime('now'))
);

CREATE INDEX IF NOT EXISTS idx_work_execution_resources_record
    ON work_execution_resources(execution_record_id);

CREATE TABLE IF NOT EXISTS dwe_agent_recommendations (
    id                  TEXT PRIMARY KEY NOT NULL,
    unternehmen_id      TEXT NOT NULL,
    agent_id            TEXT,
    project_id          TEXT NOT NULL,
    work_pack_id        TEXT,
    execution_record_id TEXT,
    issue               TEXT NOT NULL,
    evidence            TEXT,
    risk_level          TEXT NOT NULL DEFAULT 'medium',
    recommended_action  TEXT NOT NULL,
    owner               TEXT,
    status              TEXT NOT NULL DEFAULT 'pending_review',
    detected_am         TEXT NOT NULL DEFAULT (datetime('now')),
    reviewed_am         TEXT,
    erstellt_am         TEXT NOT NULL DEFAULT (datetime('now'))
);

CREATE INDEX IF NOT EXISTS idx_dwe_agent_recs_project
    ON dwe_agent_recommendations(project_id);
CREATE INDEX IF NOT EXISTS idx_dwe_agent_recs_status
    ON dwe_agent_recommendations(status);
