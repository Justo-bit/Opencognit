-- =============================================================================
-- Migration 0086: PR-QC-2 — NCR, Corrective Actions, Test Results
-- =============================================================================

CREATE TABLE IF NOT EXISTS non_conformance_reports (
    id                  TEXT PRIMARY KEY NOT NULL,
    unternehmen_id      TEXT NOT NULL,
    project_id          TEXT NOT NULL,
    inspection_id       TEXT,
    activity_id         TEXT,
    ncr_number          TEXT,
    title               TEXT NOT NULL,
    description         TEXT NOT NULL,
    ncr_type            TEXT NOT NULL DEFAULT 'minor',
    severity            TEXT NOT NULL DEFAULT 'low',
    raised_by           TEXT NOT NULL,
    raised_am           TEXT NOT NULL DEFAULT (datetime('now')),
    root_cause          TEXT,
    disposition         TEXT,
    disposition_by      TEXT,
    disposition_am      TEXT,
    cost_impact         REAL DEFAULT 0,
    schedule_impact_days INTEGER DEFAULT 0,
    status              TEXT NOT NULL DEFAULT 'open',
    closed_by           TEXT,
    closed_am           TEXT,
    notes               TEXT,
    erstellt_am         TEXT NOT NULL DEFAULT (datetime('now')),
    aktualisiert_am     TEXT NOT NULL DEFAULT (datetime('now'))
);

CREATE INDEX IF NOT EXISTS idx_ncr_project ON non_conformance_reports(project_id);
CREATE INDEX IF NOT EXISTS idx_ncr_status ON non_conformance_reports(status);
CREATE INDEX IF NOT EXISTS idx_ncr_severity ON non_conformance_reports(severity);

CREATE TABLE IF NOT EXISTS ncr_corrective_actions (
    id                  TEXT PRIMARY KEY NOT NULL,
    ncr_id              TEXT NOT NULL,
    sequence_number     INTEGER NOT NULL,
    action_description  TEXT NOT NULL,
    responsible_party   TEXT NOT NULL,
    target_date         TEXT,
    completed           INTEGER NOT NULL DEFAULT 0,
    completed_by        TEXT,
    completed_am        TEXT,
    evidence            TEXT,
    verified_by         TEXT,
    verified_am         TEXT,
    erstellt_am         TEXT NOT NULL DEFAULT (datetime('now'))
);

CREATE INDEX IF NOT EXISTS idx_ncr_corrective_actions_ncr
    ON ncr_corrective_actions(ncr_id);

CREATE TABLE IF NOT EXISTS test_results (
    id                  TEXT PRIMARY KEY NOT NULL,
    unternehmen_id      TEXT NOT NULL,
    project_id          TEXT NOT NULL,
    inspection_id       TEXT,
    itp_checkpoint_id   TEXT,
    test_name           TEXT NOT NULL,
    test_type           TEXT NOT NULL,
    test_standard       TEXT,
    sample_id           TEXT,
    test_value          TEXT,
    acceptable_range    TEXT,
    passed              INTEGER NOT NULL DEFAULT 0,
    tested_by           TEXT NOT NULL,
    tested_am           TEXT NOT NULL DEFAULT (datetime('now')),
    equipment_used      TEXT,
    certificate_ref     TEXT,
    notes               TEXT,
    erstellt_am         TEXT NOT NULL DEFAULT (datetime('now'))
);

CREATE INDEX IF NOT EXISTS idx_test_results_inspection
    ON test_results(inspection_id);
CREATE INDEX IF NOT EXISTS idx_test_results_project
    ON test_results(project_id);

CREATE TABLE IF NOT EXISTS qc_hold_points (
    id                  TEXT PRIMARY KEY NOT NULL,
    unternehmen_id      TEXT NOT NULL,
    project_id          TEXT NOT NULL,
    activity_id         TEXT,
    itp_checkpoint_id   TEXT,
    description         TEXT NOT NULL,
    hold_reason         TEXT NOT NULL,
    placed_by           TEXT NOT NULL,
    placed_am           TEXT NOT NULL DEFAULT (datetime('now')),
    released_by         TEXT,
    released_am         TEXT,
    release_conditions  TEXT,
    status              TEXT NOT NULL DEFAULT 'active',
    erstellt_am         TEXT NOT NULL DEFAULT (datetime('now'))
);

CREATE INDEX IF NOT EXISTS idx_qc_hold_points_project
    ON qc_hold_points(project_id);
CREATE INDEX IF NOT EXISTS idx_qc_hold_points_status
    ON qc_hold_points(status);

CREATE TABLE IF NOT EXISTS qc_reviews (
    id                  TEXT PRIMARY KEY NOT NULL,
    unternehmen_id      TEXT NOT NULL,
    project_id          TEXT NOT NULL,
    reviewed_by         TEXT NOT NULL,
    rolle               TEXT NOT NULL DEFAULT 'qc_engineer',
    review_type         TEXT NOT NULL DEFAULT 'daily',
    decision            TEXT NOT NULL DEFAULT 'no_action',
    comments            TEXT,
    reviewed_am         TEXT NOT NULL DEFAULT (datetime('now')),
    erstellt_am         TEXT NOT NULL DEFAULT (datetime('now'))
);

CREATE INDEX IF NOT EXISTS idx_qc_reviews_project
    ON qc_reviews(project_id);
