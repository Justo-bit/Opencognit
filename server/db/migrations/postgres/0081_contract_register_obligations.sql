-- =============================================================================
-- Migration 0081: PR-CON-1 — Contract Register + Obligations Backbone
-- =============================================================================

CREATE TABLE IF NOT EXISTS contracts (
    id                      SERIAL PRIMARY KEY,
    unternehmen_id          TEXT NOT NULL,
    project_id              TEXT NOT NULL,
    award_id                TEXT,
    contract_number         TEXT,
    title                   TEXT NOT NULL,
    contract_type           TEXT NOT NULL DEFAULT 'main_contract',
    counterparty_name       TEXT NOT NULL,
    counterparty_id         TEXT,
    scope_of_work           TEXT,
    contract_sum            DOUBLE PRECISION NOT NULL DEFAULT 0,
    contingency_sum         DOUBLE PRECISION DEFAULT 0,
    currency                TEXT DEFAULT 'KES',
    start_date              TEXT NOT NULL,
    end_date                TEXT NOT NULL,
    original_completion_date TEXT,
    current_completion_date  TEXT,
    signed_date             TEXT,
    governing_law           TEXT,
    dispute_resolution      TEXT,
    bond_type               TEXT,
    bond_amount             DOUBLE PRECISION,
    bond_expiry             TEXT,
    retention_pct           DOUBLE PRECISION DEFAULT 0,
    retention_cap           DOUBLE PRECISION,
    defects_liability_months INTEGER DEFAULT 12,
    status                  TEXT NOT NULL DEFAULT 'draft',
    terminated_reason       TEXT,
    terminated_date         TEXT,
    notes                   TEXT,
    erstellt_am             TEXT NOT NULL DEFAULT (NOW()),
    aktualisiert_am         TEXT NOT NULL DEFAULT (NOW())
);

CREATE INDEX IF NOT EXISTS idx_contracts_project ON contracts(project_id);
CREATE INDEX IF NOT EXISTS idx_contracts_status ON contracts(status);
CREATE INDEX IF NOT EXISTS idx_contracts_type ON contracts(contract_type);

CREATE TABLE IF NOT EXISTS contract_parties (
    id                      SERIAL PRIMARY KEY,
    contract_id             TEXT NOT NULL,
    party_name              TEXT NOT NULL,
    party_role              TEXT NOT NULL DEFAULT 'contractor',
    contact_person          TEXT,
    contact_email           TEXT,
    contact_phone           TEXT,
    address                 TEXT,
    signing_authority       TEXT,
    signed_date             TEXT,
    erstellt_am             TEXT NOT NULL DEFAULT (NOW())
);

CREATE INDEX IF NOT EXISTS idx_contract_parties_contract
    ON contract_parties(contract_id);

CREATE TABLE IF NOT EXISTS contract_clauses (
    id                      SERIAL PRIMARY KEY,
    contract_id             TEXT NOT NULL,
    clause_number           TEXT NOT NULL,
    clause_title            TEXT NOT NULL,
    clause_text             TEXT,
    clause_type             TEXT NOT NULL DEFAULT 'general',
    is_critical             INTEGER NOT NULL DEFAULT 0,
    deviation_from_standard TEXT,
    risk_level              TEXT DEFAULT 'low',
    notes                   TEXT,
    erstellt_am             TEXT NOT NULL DEFAULT (NOW())
);

CREATE INDEX IF NOT EXISTS idx_contract_clauses_contract
    ON contract_clauses(contract_id);
CREATE INDEX IF NOT EXISTS idx_contract_clauses_type
    ON contract_clauses(clause_type);

CREATE TABLE IF NOT EXISTS contract_obligations (
    id                      SERIAL PRIMARY KEY,
    contract_id             TEXT NOT NULL,
    clause_id               TEXT,
    obligation_type         TEXT NOT NULL,
    description             TEXT NOT NULL,
    responsible_party       TEXT NOT NULL,
    due_date                TEXT,
    reminder_days           INTEGER DEFAULT 7,
    fulfilled               INTEGER NOT NULL DEFAULT 0,
    fulfilled_date          TEXT,
    fulfilled_by            TEXT,
    evidence                TEXT,
    notes                   TEXT,
    erstellt_am             TEXT NOT NULL DEFAULT (NOW()),
    aktualisiert_am         TEXT NOT NULL DEFAULT (NOW())
);

CREATE INDEX IF NOT EXISTS idx_contract_obligations_contract
    ON contract_obligations(contract_id);
CREATE INDEX IF NOT EXISTS idx_contract_obligations_due
    ON contract_obligations(due_date);

CREATE TABLE IF NOT EXISTS contract_documents (
    id                      SERIAL PRIMARY KEY,
    contract_id             TEXT NOT NULL,
    document_type           TEXT NOT NULL,
    document_title          TEXT NOT NULL,
    file_path               TEXT,
    version                 INTEGER DEFAULT 1,
    is_current              INTEGER NOT NULL DEFAULT 1,
    uploaded_by             TEXT,
    uploaded_am             TEXT NOT NULL DEFAULT (NOW()),
    notes                   TEXT,
    erstellt_am             TEXT NOT NULL DEFAULT (NOW())
);

CREATE INDEX IF NOT EXISTS idx_contract_documents_contract
    ON contract_documents(contract_id);

CREATE TABLE IF NOT EXISTS contract_agent_recommendations (
    id                      SERIAL PRIMARY KEY,
    unternehmen_id          TEXT NOT NULL,
    agent_id                TEXT,
    contract_id             TEXT NOT NULL,
    issue                   TEXT NOT NULL,
    evidence                TEXT,
    risk_level              TEXT NOT NULL DEFAULT 'medium',
    recommended_action      TEXT NOT NULL,
    owner                   TEXT,
    status                  TEXT NOT NULL DEFAULT 'pending_review',
    detected_am             TEXT NOT NULL DEFAULT (NOW()),
    reviewed_am             TEXT,
    erstellt_am             TEXT NOT NULL DEFAULT (NOW())
);

CREATE INDEX IF NOT EXISTS idx_contract_agent_recs_contract
    ON contract_agent_recommendations(contract_id);
CREATE INDEX IF NOT EXISTS idx_contract_agent_recs_status
    ON contract_agent_recommendations(status);
