-- =============================================================================
-- Migration 0085: PR-QC-1 — Inspection + Test Plan Backbone
-- =============================================================================

CREATE TABLE IF NOT EXISTS inspection_test_plans (
    id                  TEXT PRIMARY KEY NOT NULL,
    unternehmen_id      TEXT NOT NULL,
    project_id          TEXT NOT NULL,
    activity_id         TEXT,
    boq_item_id         TEXT,
    itp_number          TEXT,
    title               TEXT NOT NULL,
    description         TEXT,
    discipline          TEXT NOT NULL DEFAULT 'civil',
    specification_ref   TEXT,
    drawing_ref         TEXT,
    prepared_by         TEXT NOT NULL,
    approved_by         TEXT,
    approved_am         TEXT,
    status              TEXT NOT NULL DEFAULT 'draft',
    notes               TEXT,
    erstellt_am         TEXT NOT NULL DEFAULT (datetime('now')),
    aktualisiert_am     TEXT NOT NULL DEFAULT (datetime('now'))
);

CREATE INDEX IF NOT EXISTS idx_itp_project ON inspection_test_plans(project_id);
CREATE INDEX IF NOT EXISTS idx_itp_activity ON inspection_test_plans(activity_id);

CREATE TABLE IF NOT EXISTS itp_checkpoints (
    id                  TEXT PRIMARY KEY NOT NULL,
    itp_id              TEXT NOT NULL,
    sequence_number     INTEGER NOT NULL,
    checkpoint_type     TEXT NOT NULL DEFAULT 'hold_point',
    description         TEXT NOT NULL,
    acceptance_criteria TEXT,
    test_method         TEXT,
    frequency           TEXT,
    responsible_party   TEXT,
    witness_required    INTEGER NOT NULL DEFAULT 0,
    witness_role        TEXT,
    status              TEXT NOT NULL DEFAULT 'pending',
    inspected_by        TEXT,
    inspected_am        TEXT,
    result              TEXT,
    comments            TEXT,
    erstellt_am         TEXT NOT NULL DEFAULT (datetime('now'))
);

CREATE INDEX IF NOT EXISTS idx_itp_checkpoints_itp
    ON itp_checkpoints(itp_id);

CREATE TABLE IF NOT EXISTS material_inspections (
    id                  TEXT PRIMARY KEY NOT NULL,
    unternehmen_id      TEXT NOT NULL,
    project_id          TEXT NOT NULL,
    grn_id              TEXT,
    grn_item_id         TEXT,
    material_name       TEXT NOT NULL,
    batch_number        TEXT,
    quantity_inspected  REAL NOT NULL,
    quantity_passed     REAL NOT NULL DEFAULT 0,
    quantity_rejected   REAL NOT NULL DEFAULT 0,
    inspection_type     TEXT NOT NULL DEFAULT 'visual',
    test_results        TEXT,
    standard_ref        TEXT,
    inspected_by        TEXT NOT NULL,
    inspected_am        TEXT NOT NULL DEFAULT (datetime('now')),
    result              TEXT NOT NULL DEFAULT 'pending',
    rejection_reason    TEXT,
    notes               TEXT,
    erstellt_am         TEXT NOT NULL DEFAULT (datetime('now'))
);

CREATE INDEX IF NOT EXISTS idx_material_inspections_grn
    ON material_inspections(grn_id);
CREATE INDEX IF NOT EXISTS idx_material_inspections_project
    ON material_inspections(project_id);

CREATE TABLE IF NOT EXISTS work_inspections (
    id                  TEXT PRIMARY KEY NOT NULL,
    unternehmen_id      TEXT NOT NULL,
    project_id          TEXT NOT NULL,
    activity_id         TEXT,
    daily_work_pack_id  TEXT,
    itp_checkpoint_id   TEXT,
    inspection_type     TEXT NOT NULL DEFAULT 'in_process',
    description         TEXT NOT NULL,
    location            TEXT,
    inspected_by        TEXT NOT NULL,
    inspected_am        TEXT NOT NULL DEFAULT (datetime('now')),
    result              TEXT NOT NULL DEFAULT 'pending',
    defects_found       INTEGER DEFAULT 0,
    rework_required     INTEGER NOT NULL DEFAULT 0,
    witness_present     TEXT,
    notes               TEXT,
    erstellt_am         TEXT NOT NULL DEFAULT (datetime('now'))
);

CREATE INDEX IF NOT EXISTS idx_work_inspections_activity
    ON work_inspections(activity_id);
CREATE INDEX IF NOT EXISTS idx_work_inspections_pack
    ON work_inspections(daily_work_pack_id);

CREATE TABLE IF NOT EXISTS qc_agent_recommendations (
    id                  TEXT PRIMARY KEY NOT NULL,
    unternehmen_id      TEXT NOT NULL,
    agent_id            TEXT,
    project_id          TEXT NOT NULL,
    itp_id              TEXT,
    inspection_id       TEXT,
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

CREATE INDEX IF NOT EXISTS idx_qc_agent_recs_project
    ON qc_agent_recommendations(project_id);
CREATE INDEX IF NOT EXISTS idx_qc_agent_recs_status
    ON qc_agent_recommendations(status);
