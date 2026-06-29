-- =============================================================================
-- Migration 0087: PR-IPC-1 — BOQ-vs-Actual + IPC Backbone
-- =============================================================================

CREATE TABLE IF NOT EXISTS ipc_certificates (
    id                  TEXT PRIMARY KEY NOT NULL,
    unternehmen_id      TEXT NOT NULL,
    project_id          TEXT NOT NULL,
    contract_id         TEXT NOT NULL,
    ipc_number          TEXT,
    period_start        TEXT NOT NULL,
    period_end          TEXT NOT NULL,
    valuation_date      TEXT NOT NULL DEFAULT (datetime('now')),
    work_done_this_period REAL NOT NULL DEFAULT 0,
    cumulative_work_done REAL NOT NULL DEFAULT 0,
    retention_this_period REAL DEFAULT 0,
    cumulative_retention REAL DEFAULT 0,
    advance_recovery    REAL DEFAULT 0,
    variation_amount    REAL DEFAULT 0,
    claim_amount        REAL DEFAULT 0,
    certified_amount    REAL DEFAULT 0,
    previously_certified REAL DEFAULT 0,
    amount_due          REAL NOT NULL DEFAULT 0,
    currency            TEXT DEFAULT 'KES',
    prepared_by         TEXT NOT NULL,
    status              TEXT NOT NULL DEFAULT 'draft',
    certified_by        TEXT,
    certified_am        TEXT,
    certification_ref   TEXT,
    notes               TEXT,
    erstellt_am         TEXT NOT NULL DEFAULT (datetime('now')),
    aktualisiert_am     TEXT NOT NULL DEFAULT (datetime('now'))
);

CREATE INDEX IF NOT EXISTS idx_ipc_project ON ipc_certificates(project_id);
CREATE INDEX IF NOT EXISTS idx_ipc_status ON ipc_certificates(status);
CREATE INDEX IF NOT EXISTS idx_ipc_contract ON ipc_certificates(contract_id);

CREATE TABLE IF NOT EXISTS ipc_items (
    id                  TEXT PRIMARY KEY NOT NULL,
    ipc_id              TEXT NOT NULL,
    boq_item_id         TEXT NOT NULL,
    item_description    TEXT NOT NULL,
    boq_quantity        REAL NOT NULL DEFAULT 0,
    previous_quantity   REAL NOT NULL DEFAULT 0,
    this_period_quantity REAL NOT NULL DEFAULT 0,
    cumulative_quantity REAL NOT NULL DEFAULT 0,
    remaining_quantity  REAL NOT NULL DEFAULT 0,
    unit                TEXT NOT NULL DEFAULT 'No.',
    unit_rate           REAL NOT NULL DEFAULT 0,
    this_period_amount  REAL NOT NULL DEFAULT 0,
    cumulative_amount   REAL NOT NULL DEFAULT 0,
    measurement_basis   TEXT,
    notes               TEXT,
    erstellt_am         TEXT NOT NULL DEFAULT (datetime('now'))
);

CREATE INDEX IF NOT EXISTS idx_ipc_items_ipc ON ipc_items(ipc_id);
CREATE INDEX IF NOT EXISTS idx_ipc_items_boq ON ipc_items(boq_item_id);

CREATE TABLE IF NOT EXISTS measurement_sheets (
    id                  TEXT PRIMARY KEY NOT NULL,
    ipc_item_id         TEXT NOT NULL,
    description         TEXT NOT NULL,
    measurement_type    TEXT NOT NULL DEFAULT 'field_measure',
    location            TEXT,
    dimension_length    REAL,
    dimension_width     REAL,
    dimension_height    REAL,
    quantity            REAL NOT NULL,
    unit                TEXT NOT NULL DEFAULT 'm3',
    measured_by         TEXT NOT NULL,
    measured_am         TEXT NOT NULL DEFAULT (datetime('now')),
    checked_by          TEXT,
    checked_am          TEXT,
    sketch_ref          TEXT,
    photo_ref           TEXT,
    erstellt_am         TEXT NOT NULL DEFAULT (datetime('now'))
);

CREATE INDEX IF NOT EXISTS idx_measurement_sheets_ipc_item
    ON measurement_sheets(ipc_item_id);

CREATE TABLE IF NOT EXISTS boq_vs_actual_records (
    id                  TEXT PRIMARY KEY NOT NULL,
    unternehmen_id      TEXT NOT NULL,
    project_id          TEXT NOT NULL,
    boq_item_id         TEXT NOT NULL,
    budget_quantity     REAL NOT NULL DEFAULT 0,
    budget_amount       REAL NOT NULL DEFAULT 0,
    actual_quantity     REAL NOT NULL DEFAULT 0,
    actual_amount       REAL NOT NULL DEFAULT 0,
    quantity_variance   REAL NOT NULL DEFAULT 0,
    amount_variance     REAL NOT NULL DEFAULT 0,
    variance_pct        REAL NOT NULL DEFAULT 0,
    as_of_date          TEXT NOT NULL,
    notes               TEXT,
    erstellt_am         TEXT NOT NULL DEFAULT (datetime('now'))
);

CREATE INDEX IF NOT EXISTS idx_boq_vs_actual_project
    ON boq_vs_actual_records(project_id);
CREATE INDEX IF NOT EXISTS idx_boq_vs_actual_boq
    ON boq_vs_actual_records(boq_item_id);

CREATE TABLE IF NOT EXISTS ipc_agent_recommendations (
    id                  TEXT PRIMARY KEY NOT NULL,
    unternehmen_id      TEXT NOT NULL,
    agent_id            TEXT,
    project_id          TEXT NOT NULL,
    ipc_id              TEXT,
    boq_item_id         TEXT,
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

CREATE INDEX IF NOT EXISTS idx_ipc_agent_recs_project
    ON ipc_agent_recommendations(project_id);
CREATE INDEX IF NOT EXISTS idx_ipc_agent_recs_status
    ON ipc_agent_recommendations(status);
