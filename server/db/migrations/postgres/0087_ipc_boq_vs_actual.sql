-- =============================================================================
-- Migration 0087: PR-IPC-1 — BOQ-vs-Actual + IPC Backbone
-- =============================================================================

CREATE TABLE IF NOT EXISTS ipc_certificates (
    id                  SERIAL PRIMARY KEY,
    unternehmen_id      TEXT NOT NULL,
    project_id          TEXT NOT NULL,
    contract_id         TEXT NOT NULL,
    ipc_number          TEXT,
    period_start        TEXT NOT NULL,
    period_end          TEXT NOT NULL,
    valuation_date      TEXT NOT NULL DEFAULT (NOW()),
    work_done_this_period DOUBLE PRECISION NOT NULL DEFAULT 0,
    cumulative_work_done DOUBLE PRECISION NOT NULL DEFAULT 0,
    retention_this_period DOUBLE PRECISION DEFAULT 0,
    cumulative_retention DOUBLE PRECISION DEFAULT 0,
    advance_recovery    DOUBLE PRECISION DEFAULT 0,
    variation_amount    DOUBLE PRECISION DEFAULT 0,
    claim_amount        DOUBLE PRECISION DEFAULT 0,
    certified_amount    DOUBLE PRECISION DEFAULT 0,
    previously_certified DOUBLE PRECISION DEFAULT 0,
    amount_due          DOUBLE PRECISION NOT NULL DEFAULT 0,
    currency            TEXT DEFAULT 'KES',
    prepared_by         TEXT NOT NULL,
    status              TEXT NOT NULL DEFAULT 'draft',
    certified_by        TEXT,
    certified_am        TEXT,
    certification_ref   TEXT,
    notes               TEXT,
    erstellt_am         TEXT NOT NULL DEFAULT (NOW()),
    aktualisiert_am     TEXT NOT NULL DEFAULT (NOW())
);

CREATE INDEX IF NOT EXISTS idx_ipc_project ON ipc_certificates(project_id);
CREATE INDEX IF NOT EXISTS idx_ipc_status ON ipc_certificates(status);
CREATE INDEX IF NOT EXISTS idx_ipc_contract ON ipc_certificates(contract_id);

CREATE TABLE IF NOT EXISTS ipc_items (
    id                  SERIAL PRIMARY KEY,
    ipc_id              TEXT NOT NULL,
    boq_item_id         TEXT NOT NULL,
    item_description    TEXT NOT NULL,
    boq_quantity        DOUBLE PRECISION NOT NULL DEFAULT 0,
    previous_quantity   DOUBLE PRECISION NOT NULL DEFAULT 0,
    this_period_quantity DOUBLE PRECISION NOT NULL DEFAULT 0,
    cumulative_quantity DOUBLE PRECISION NOT NULL DEFAULT 0,
    remaining_quantity  DOUBLE PRECISION NOT NULL DEFAULT 0,
    unit                TEXT NOT NULL DEFAULT 'No.',
    unit_rate           DOUBLE PRECISION NOT NULL DEFAULT 0,
    this_period_amount  DOUBLE PRECISION NOT NULL DEFAULT 0,
    cumulative_amount   DOUBLE PRECISION NOT NULL DEFAULT 0,
    measurement_basis   TEXT,
    notes               TEXT,
    erstellt_am         TEXT NOT NULL DEFAULT (NOW())
);

CREATE INDEX IF NOT EXISTS idx_ipc_items_ipc ON ipc_items(ipc_id);
CREATE INDEX IF NOT EXISTS idx_ipc_items_boq ON ipc_items(boq_item_id);

CREATE TABLE IF NOT EXISTS measurement_sheets (
    id                  SERIAL PRIMARY KEY,
    ipc_item_id         TEXT NOT NULL,
    description         TEXT NOT NULL,
    measurement_type    TEXT NOT NULL DEFAULT 'field_measure',
    location            TEXT,
    dimension_length    DOUBLE PRECISION,
    dimension_width     DOUBLE PRECISION,
    dimension_height    DOUBLE PRECISION,
    quantity            DOUBLE PRECISION NOT NULL,
    unit                TEXT NOT NULL DEFAULT 'm3',
    measured_by         TEXT NOT NULL,
    measured_am         TEXT NOT NULL DEFAULT (NOW()),
    checked_by          TEXT,
    checked_am          TEXT,
    sketch_ref          TEXT,
    photo_ref           TEXT,
    erstellt_am         TEXT NOT NULL DEFAULT (NOW())
);

CREATE INDEX IF NOT EXISTS idx_measurement_sheets_ipc_item
    ON measurement_sheets(ipc_item_id);

CREATE TABLE IF NOT EXISTS boq_vs_actual_records (
    id                  SERIAL PRIMARY KEY,
    unternehmen_id      TEXT NOT NULL,
    project_id          TEXT NOT NULL,
    boq_item_id         TEXT NOT NULL,
    budget_quantity     DOUBLE PRECISION NOT NULL DEFAULT 0,
    budget_amount       DOUBLE PRECISION NOT NULL DEFAULT 0,
    actual_quantity     DOUBLE PRECISION NOT NULL DEFAULT 0,
    actual_amount       DOUBLE PRECISION NOT NULL DEFAULT 0,
    quantity_variance   DOUBLE PRECISION NOT NULL DEFAULT 0,
    amount_variance     DOUBLE PRECISION NOT NULL DEFAULT 0,
    variance_pct        DOUBLE PRECISION NOT NULL DEFAULT 0,
    as_of_date          TEXT NOT NULL,
    notes               TEXT,
    erstellt_am         TEXT NOT NULL DEFAULT (NOW())
);

CREATE INDEX IF NOT EXISTS idx_boq_vs_actual_project
    ON boq_vs_actual_records(project_id);
CREATE INDEX IF NOT EXISTS idx_boq_vs_actual_boq
    ON boq_vs_actual_records(boq_item_id);

CREATE TABLE IF NOT EXISTS ipc_agent_recommendations (
    id                  SERIAL PRIMARY KEY,
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
    detected_am         TEXT NOT NULL DEFAULT (NOW()),
    reviewed_am         TEXT,
    erstellt_am         TEXT NOT NULL DEFAULT (NOW())
);

CREATE INDEX IF NOT EXISTS idx_ipc_agent_recs_project
    ON ipc_agent_recommendations(project_id);
CREATE INDEX IF NOT EXISTS idx_ipc_agent_recs_status
    ON ipc_agent_recommendations(status);
