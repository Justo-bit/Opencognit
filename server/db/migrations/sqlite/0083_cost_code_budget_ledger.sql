-- =============================================================================
-- Migration 0083: PR-FIN-1 — Cost Code + Budget Ledger Backbone
-- =============================================================================

CREATE TABLE IF NOT EXISTS cost_codes (
    id                  TEXT PRIMARY KEY NOT NULL,
    unternehmen_id      TEXT NOT NULL,
    project_id          TEXT NOT NULL,
    code                TEXT NOT NULL,
    description         TEXT NOT NULL,
    parent_cost_code_id TEXT,
    level               INTEGER NOT NULL DEFAULT 1,
    category            TEXT NOT NULL DEFAULT 'direct_cost',
    is_active           INTEGER NOT NULL DEFAULT 1,
    notes               TEXT,
    erstellt_am         TEXT NOT NULL DEFAULT (datetime('now'))
);

CREATE INDEX IF NOT EXISTS idx_cost_codes_project
    ON cost_codes(project_id);
CREATE INDEX IF NOT EXISTS idx_cost_codes_parent
    ON cost_codes(parent_cost_code_id);
CREATE UNIQUE INDEX IF NOT EXISTS idx_cost_codes_code_project
    ON cost_codes(project_id, code);

CREATE TABLE IF NOT EXISTS project_budget_lines (
    id                  TEXT PRIMARY KEY NOT NULL,
    unternehmen_id      TEXT NOT NULL,
    project_id          TEXT NOT NULL,
    cost_code_id        TEXT NOT NULL,
    boq_item_id         TEXT,
    description         TEXT NOT NULL,
    budget_amount       REAL NOT NULL DEFAULT 0,
    contingency_amount  REAL DEFAULT 0,
    total_budget        REAL NOT NULL DEFAULT 0,
    currency            TEXT DEFAULT 'KES',
    fiscal_year         TEXT,
    status              TEXT NOT NULL DEFAULT 'active',
    approved_by         TEXT,
    approved_am         TEXT,
    notes               TEXT,
    erstellt_am         TEXT NOT NULL DEFAULT (datetime('now')),
    aktualisiert_am     TEXT NOT NULL DEFAULT (datetime('now'))
);

CREATE INDEX IF NOT EXISTS idx_project_budget_lines_project
    ON project_budget_lines(project_id);
CREATE INDEX IF NOT EXISTS idx_project_budget_lines_cost_code
    ON project_budget_lines(cost_code_id);

CREATE TABLE IF NOT EXISTS financial_ledger_entries (
    id                  TEXT PRIMARY KEY NOT NULL,
    unternehmen_id      TEXT NOT NULL,
    project_id          TEXT NOT NULL,
    cost_code_id        TEXT NOT NULL,
    boq_item_id         TEXT,
    activity_id         TEXT,
    transaction_type    TEXT NOT NULL,
    amount              REAL NOT NULL,
    currency            TEXT DEFAULT 'KES',
    source_document_type TEXT,
    source_document_id  TEXT,
    vendor_id           TEXT,
    subcontractor_id    TEXT,
    worker_id           TEXT,
    equipment_id        TEXT,
    description         TEXT NOT NULL,
    entry_date          TEXT NOT NULL,
    posted_by           TEXT,
    approval_status     TEXT NOT NULL DEFAULT 'posted',
    reversal_of         TEXT,
    reversed_by_entry   TEXT,
    notes               TEXT,
    erstellt_am         TEXT NOT NULL DEFAULT (datetime('now'))
);

CREATE INDEX IF NOT EXISTS idx_financial_ledger_entries_project
    ON financial_ledger_entries(project_id);
CREATE INDEX IF NOT EXISTS idx_financial_ledger_entries_cost_code
    ON financial_ledger_entries(cost_code_id);
CREATE INDEX IF NOT EXISTS idx_financial_ledger_entries_type
    ON financial_ledger_entries(transaction_type);
CREATE INDEX IF NOT EXISTS idx_financial_ledger_entries_date
    ON financial_ledger_entries(entry_date);
CREATE INDEX IF NOT EXISTS idx_financial_ledger_entries_source
    ON financial_ledger_entries(source_document_type, source_document_id);

CREATE TABLE IF NOT EXISTS finance_agent_recommendations (
    id                  TEXT PRIMARY KEY NOT NULL,
    unternehmen_id      TEXT NOT NULL,
    agent_id            TEXT,
    project_id          TEXT NOT NULL,
    cost_code_id        TEXT,
    issue               TEXT NOT NULL,
    evidence            TEXT,
    risk_level          TEXT NOT NULL DEFAULT 'medium',
    financial_impact    REAL DEFAULT 0,
    recommended_action  TEXT NOT NULL,
    owner               TEXT,
    status              TEXT NOT NULL DEFAULT 'pending_review',
    detected_am         TEXT NOT NULL DEFAULT (datetime('now')),
    reviewed_am         TEXT,
    erstellt_am         TEXT NOT NULL DEFAULT (datetime('now'))
);

CREATE INDEX IF NOT EXISTS idx_finance_agent_recs_project
    ON finance_agent_recommendations(project_id);
CREATE INDEX IF NOT EXISTS idx_finance_agent_recs_status
    ON finance_agent_recommendations(status);
