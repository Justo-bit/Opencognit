-- =============================================================================
-- Migration 0088: PR-IPC-2+ — Retention, Advance, Subcontractor, Approvals
-- =============================================================================

CREATE TABLE IF NOT EXISTS ipc_retention_records (
    id                  SERIAL PRIMARY KEY,
    ipc_id              TEXT NOT NULL,
    retention_pct       DOUBLE PRECISION NOT NULL DEFAULT 0,
    retention_amount    DOUBLE PRECISION NOT NULL DEFAULT 0,
    cumulative_retained DOUBLE PRECISION NOT NULL DEFAULT 0,
    release_eligible    DOUBLE PRECISION NOT NULL DEFAULT 0,
    released_amount     DOUBLE PRECISION NOT NULL DEFAULT 0,
    release_date        TEXT,
    released_by         TEXT,
    status              TEXT NOT NULL DEFAULT 'held',
    notes               TEXT,
    erstellt_am         TEXT NOT NULL DEFAULT (NOW())
);
CREATE INDEX IF NOT EXISTS idx_ipc_retention_ipc ON ipc_retention_records(ipc_id);

CREATE TABLE IF NOT EXISTS advance_payment_records (
    id                  SERIAL PRIMARY KEY,
    unternehmen_id      TEXT NOT NULL,
    project_id          TEXT NOT NULL,
    contract_id         TEXT NOT NULL,
    advance_amount      DOUBLE PRECISION NOT NULL,
    recovery_pct        DOUBLE PRECISION NOT NULL DEFAULT 0,
    recovered_to_date   DOUBLE PRECISION NOT NULL DEFAULT 0,
    remaining_balance   DOUBLE PRECISION NOT NULL DEFAULT 0,
    advance_date        TEXT NOT NULL,
    recovery_start_ipc  TEXT,
    bonded              INTEGER NOT NULL DEFAULT 0,
    bond_ref            TEXT,
    status              TEXT NOT NULL DEFAULT 'active',
    notes               TEXT,
    erstellt_am         TEXT NOT NULL DEFAULT (NOW()),
    aktualisiert_am     TEXT NOT NULL DEFAULT (NOW())
);
CREATE INDEX IF NOT EXISTS idx_advance_payment_project ON advance_payment_records(project_id);

CREATE TABLE IF NOT EXISTS subcontractor_ipc_claims (
    id                  SERIAL PRIMARY KEY,
    unternehmen_id      TEXT NOT NULL,
    project_id          TEXT NOT NULL,
    ipc_id              TEXT,
    subcontractor_id    TEXT NOT NULL,
    contract_id         TEXT NOT NULL,
    claim_number        TEXT,
    description         TEXT NOT NULL,
    claimed_amount      DOUBLE PRECISION NOT NULL DEFAULT 0,
    certified_amount    DOUBLE PRECISION DEFAULT 0,
    retention_deducted  DOUBLE PRECISION DEFAULT 0,
    previously_certified DOUBLE PRECISION DEFAULT 0,
    amount_due          DOUBLE PRECISION NOT NULL DEFAULT 0,
    status              TEXT NOT NULL DEFAULT 'draft',
    certified_by        TEXT,
    certified_am        TEXT,
    notes               TEXT,
    erstellt_am         TEXT NOT NULL DEFAULT (NOW()),
    aktualisiert_am     TEXT NOT NULL DEFAULT (NOW())
);
CREATE INDEX IF NOT EXISTS idx_subcontractor_ipc_project ON subcontractor_ipc_claims(project_id);
CREATE INDEX IF NOT EXISTS idx_subcontractor_ipc_ipc ON subcontractor_ipc_claims(ipc_id);

CREATE TABLE IF NOT EXISTS ipc_approvals (
    id                  SERIAL PRIMARY KEY,
    ipc_id              TEXT NOT NULL,
    approved_by         TEXT NOT NULL,
    rolle               TEXT NOT NULL DEFAULT 'qs',
    decision            TEXT NOT NULL DEFAULT 'pending',
    comments            TEXT,
    approved_am         TEXT NOT NULL DEFAULT (NOW()),
    erstellt_am         TEXT NOT NULL DEFAULT (NOW())
);
CREATE INDEX IF NOT EXISTS idx_ipc_approvals_ipc ON ipc_approvals(ipc_id);

CREATE TABLE IF NOT EXISTS ipc_reviews (
    id                  SERIAL PRIMARY KEY,
    unternehmen_id      TEXT NOT NULL,
    project_id          TEXT NOT NULL,
    ipc_id              TEXT NOT NULL,
    reviewed_by         TEXT NOT NULL,
    rolle               TEXT NOT NULL DEFAULT 'project_manager',
    decision            TEXT NOT NULL DEFAULT 'no_action',
    comments            TEXT,
    reviewed_am         TEXT NOT NULL DEFAULT (NOW()),
    erstellt_am         TEXT NOT NULL DEFAULT (NOW())
);
CREATE INDEX IF NOT EXISTS idx_ipc_reviews_ipc ON ipc_reviews(ipc_id);
