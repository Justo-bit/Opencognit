-- =============================================================================
-- Migration 0084: PR-FIN-2+3+4+5 — Commitments, Cashflow, Margin, Intelligence
-- =============================================================================

-- ===== Commitments + Actuals =====
CREATE TABLE IF NOT EXISTS project_commitments (
    id                  TEXT PRIMARY KEY NOT NULL,
    unternehmen_id      TEXT NOT NULL,
    project_id          TEXT NOT NULL,
    cost_code_id        TEXT NOT NULL,
    po_id               TEXT,
    subcontract_id      TEXT,
    commitment_type     TEXT NOT NULL DEFAULT 'po',
    description         TEXT NOT NULL,
    committed_amount    REAL NOT NULL,
    currency            TEXT DEFAULT 'KES',
    commitment_date     TEXT NOT NULL DEFAULT (datetime('now')),
    expected_payment_date TEXT,
    status              TEXT NOT NULL DEFAULT 'open',
    released_amount     REAL NOT NULL DEFAULT 0,
    released_date       TEXT,
    notes               TEXT,
    erstellt_am         TEXT NOT NULL DEFAULT (datetime('now')),
    aktualisiert_am     TEXT NOT NULL DEFAULT (datetime('now'))
);

CREATE INDEX IF NOT EXISTS idx_project_commitments_project
    ON project_commitments(project_id);
CREATE INDEX IF NOT EXISTS idx_project_commitments_po
    ON project_commitments(po_id);

CREATE TABLE IF NOT EXISTS project_actual_costs (
    id                  TEXT PRIMARY KEY NOT NULL,
    unternehmen_id      TEXT NOT NULL,
    project_id          TEXT NOT NULL,
    cost_code_id        TEXT NOT NULL,
    cost_type           TEXT NOT NULL,
    source_document_type TEXT,
    source_document_id  TEXT,
    description         TEXT NOT NULL,
    amount              REAL NOT NULL,
    currency            TEXT DEFAULT 'KES',
    cost_date           TEXT NOT NULL,
    posted_by           TEXT,
    notes               TEXT,
    erstellt_am         TEXT NOT NULL DEFAULT (datetime('now'))
);

CREATE INDEX IF NOT EXISTS idx_project_actual_costs_project
    ON project_actual_costs(project_id);
CREATE INDEX IF NOT EXISTS idx_project_actual_costs_code
    ON project_actual_costs(cost_code_id);

-- ===== Payables + Payments =====
CREATE TABLE IF NOT EXISTS project_payables (
    id                  TEXT PRIMARY KEY NOT NULL,
    unternehmen_id      TEXT NOT NULL,
    project_id          TEXT NOT NULL,
    vendor_id           TEXT,
    subcontractor_id    TEXT,
    invoice_id          TEXT,
    description         TEXT NOT NULL,
    payable_amount      REAL NOT NULL,
    paid_amount         REAL NOT NULL DEFAULT 0,
    currency            TEXT DEFAULT 'KES',
    due_date            TEXT,
    status              TEXT NOT NULL DEFAULT 'pending',
    priority            TEXT DEFAULT 'normal',
    notes               TEXT,
    erstellt_am         TEXT NOT NULL DEFAULT (datetime('now')),
    aktualisiert_am     TEXT NOT NULL DEFAULT (datetime('now'))
);

CREATE INDEX IF NOT EXISTS idx_project_payables_project
    ON project_payables(project_id);
CREATE INDEX IF NOT EXISTS idx_project_payables_due
    ON project_payables(due_date);

CREATE TABLE IF NOT EXISTS project_payments (
    id                  TEXT PRIMARY KEY NOT NULL,
    unternehmen_id      TEXT NOT NULL,
    project_id          TEXT NOT NULL,
    payable_id          TEXT,
    vendor_id           TEXT,
    subcontractor_id    TEXT,
    payment_type        TEXT NOT NULL,
    amount              REAL NOT NULL,
    currency            TEXT DEFAULT 'KES',
    payment_date        TEXT NOT NULL,
    payment_method      TEXT DEFAULT 'bank_transfer',
    payment_ref         TEXT,
    paid_by             TEXT NOT NULL,
    approved_by         TEXT,
    notes               TEXT,
    erstellt_am         TEXT NOT NULL DEFAULT (datetime('now'))
);

CREATE INDEX IF NOT EXISTS idx_project_payments_project
    ON project_payments(project_id);
CREATE INDEX IF NOT EXISTS idx_project_payments_date
    ON project_payments(payment_date);

-- ===== Revenue + Receivables =====
CREATE TABLE IF NOT EXISTS project_receivables (
    id                  TEXT PRIMARY KEY NOT NULL,
    unternehmen_id      TEXT NOT NULL,
    project_id          TEXT NOT NULL,
    ipc_id              TEXT,
    variation_id        TEXT,
    claim_id            TEXT,
    receivable_type     TEXT NOT NULL,
    description         TEXT NOT NULL,
    billed_amount       REAL NOT NULL,
    received_amount     REAL NOT NULL DEFAULT 0,
    retention_amount    REAL DEFAULT 0,
    currency            TEXT DEFAULT 'KES',
    invoice_date        TEXT,
    due_date            TEXT,
    status              TEXT NOT NULL DEFAULT 'pending',
    notes               TEXT,
    erstellt_am         TEXT NOT NULL DEFAULT (datetime('now')),
    aktualisiert_am     TEXT NOT NULL DEFAULT (datetime('now'))
);

CREATE INDEX IF NOT EXISTS idx_project_receivables_project
    ON project_receivables(project_id);

CREATE TABLE IF NOT EXISTS client_payment_receipts (
    id                  TEXT PRIMARY KEY NOT NULL,
    unternehmen_id      TEXT NOT NULL,
    project_id          TEXT NOT NULL,
    receivable_id       TEXT,
    amount              REAL NOT NULL,
    currency            TEXT DEFAULT 'KES',
    receipt_date        TEXT NOT NULL,
    payment_method      TEXT DEFAULT 'bank_transfer',
    payment_ref         TEXT,
    received_by         TEXT NOT NULL,
    notes               TEXT,
    erstellt_am         TEXT NOT NULL DEFAULT (datetime('now'))
);

CREATE INDEX IF NOT EXISTS idx_client_payment_receipts_project
    ON client_payment_receipts(project_id);

-- ===== Cashflow + Margin =====
CREATE TABLE IF NOT EXISTS project_cashflow_forecasts (
    id                  TEXT PRIMARY KEY NOT NULL,
    unternehmen_id      TEXT NOT NULL,
    project_id          TEXT NOT NULL,
    period_start        TEXT NOT NULL,
    period_end          TEXT NOT NULL,
    forecast_type       TEXT NOT NULL DEFAULT 'weekly',
    expected_inflows    REAL NOT NULL DEFAULT 0,
    expected_outflows   REAL NOT NULL DEFAULT 0,
    net_cashflow        REAL NOT NULL DEFAULT 0,
    running_balance     REAL NOT NULL DEFAULT 0,
    prepared_by         TEXT,
    prepared_am         TEXT NOT NULL DEFAULT (datetime('now')),
    status              TEXT NOT NULL DEFAULT 'draft',
    notes               TEXT,
    erstellt_am         TEXT NOT NULL DEFAULT (datetime('now'))
);

CREATE INDEX IF NOT EXISTS idx_project_cashflow_forecasts_project
    ON project_cashflow_forecasts(project_id);

CREATE TABLE IF NOT EXISTS project_margin_forecasts (
    id                  TEXT PRIMARY KEY NOT NULL,
    unternehmen_id      TEXT NOT NULL,
    project_id          TEXT NOT NULL,
    forecast_date       TEXT NOT NULL DEFAULT (datetime('now')),
    contract_sum        REAL NOT NULL DEFAULT 0,
    approved_variations REAL DEFAULT 0,
    potential_claims    REAL DEFAULT 0,
    forecast_revenue    REAL NOT NULL DEFAULT 0,
    approved_budget     REAL NOT NULL DEFAULT 0,
    committed_cost      REAL DEFAULT 0,
    actual_cost         REAL DEFAULT 0,
    cost_to_complete    REAL DEFAULT 0,
    forecast_final_cost REAL DEFAULT 0,
    forecast_margin     REAL NOT NULL DEFAULT 0,
    margin_pct          REAL DEFAULT 0,
    previous_margin_pct REAL,
    margin_variance     REAL,
    prepared_by         TEXT,
    status              TEXT NOT NULL DEFAULT 'draft',
    notes               TEXT,
    erstellt_am         TEXT NOT NULL DEFAULT (datetime('now'))
);

CREATE INDEX IF NOT EXISTS idx_project_margin_forecasts_project
    ON project_margin_forecasts(project_id);

-- ===== Alerts + Reviews =====
CREATE TABLE IF NOT EXISTS cost_overrun_alerts (
    id                  TEXT PRIMARY KEY NOT NULL,
    unternehmen_id      TEXT NOT NULL,
    project_id          TEXT NOT NULL,
    cost_code_id        TEXT NOT NULL,
    budget_amount       REAL NOT NULL,
    committed_amount    REAL DEFAULT 0,
    actual_amount       REAL DEFAULT 0,
    variance_pct        REAL NOT NULL DEFAULT 0,
    severity            TEXT NOT NULL DEFAULT 'warning',
    description         TEXT NOT NULL,
    acknowledged_by     TEXT,
    acknowledged_am     TEXT,
    resolution          TEXT,
    status              TEXT NOT NULL DEFAULT 'open',
    erstellt_am         TEXT NOT NULL DEFAULT (datetime('now')),
    aktualisiert_am     TEXT NOT NULL DEFAULT (datetime('now'))
);

CREATE INDEX IF NOT EXISTS idx_cost_overrun_alerts_project
    ON cost_overrun_alerts(project_id);
CREATE INDEX IF NOT EXISTS idx_cost_overrun_alerts_status
    ON cost_overrun_alerts(status);

CREATE TABLE IF NOT EXISTS finance_reviews (
    id                  TEXT PRIMARY KEY NOT NULL,
    unternehmen_id      TEXT NOT NULL,
    project_id          TEXT NOT NULL,
    reviewed_by         TEXT NOT NULL,
    rolle               TEXT NOT NULL DEFAULT 'finance_manager',
    review_type         TEXT NOT NULL DEFAULT 'monthly',
    decision            TEXT NOT NULL DEFAULT 'no_action',
    period_start        TEXT,
    period_end          TEXT,
    comments            TEXT,
    reviewed_am         TEXT NOT NULL DEFAULT (datetime('now')),
    erstellt_am         TEXT NOT NULL DEFAULT (datetime('now'))
);

CREATE INDEX IF NOT EXISTS idx_finance_reviews_project
    ON finance_reviews(project_id);
