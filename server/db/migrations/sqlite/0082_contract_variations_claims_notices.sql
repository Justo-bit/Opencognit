-- =============================================================================
-- Migration 0082: PR-CON-2+3+4+5 — Variations, Claims, Notices, Closeout
-- =============================================================================

-- ===== Variations =====
CREATE TABLE IF NOT EXISTS contract_variations (
    id                  TEXT PRIMARY KEY NOT NULL,
    unternehmen_id      TEXT NOT NULL,
    contract_id         TEXT NOT NULL,
    variation_number    TEXT,
    title               TEXT NOT NULL,
    description         TEXT,
    variation_type      TEXT NOT NULL DEFAULT 'scope_change',
    initiated_by        TEXT NOT NULL,
    initiated_date      TEXT NOT NULL DEFAULT (datetime('now')),
    cost_impact         REAL DEFAULT 0,
    time_impact_days    INTEGER DEFAULT 0,
    linked_claim_id     TEXT,
    status              TEXT NOT NULL DEFAULT 'draft',
    approved_by         TEXT,
    approved_date       TEXT,
    rejection_reason    TEXT,
    notes               TEXT,
    erstellt_am         TEXT NOT NULL DEFAULT (datetime('now')),
    aktualisiert_am     TEXT NOT NULL DEFAULT (datetime('now'))
);

CREATE INDEX IF NOT EXISTS idx_contract_variations_contract
    ON contract_variations(contract_id);
CREATE INDEX IF NOT EXISTS idx_contract_variations_status
    ON contract_variations(status);

CREATE TABLE IF NOT EXISTS variation_cost_impacts (
    id                  TEXT PRIMARY KEY NOT NULL,
    variation_id        TEXT NOT NULL,
    boq_item_id         TEXT,
    description         TEXT NOT NULL,
    quantity            REAL NOT NULL,
    unit                TEXT NOT NULL DEFAULT 'No.',
    unit_rate           REAL NOT NULL,
    total_amount        REAL NOT NULL DEFAULT 0,
    cost_code           TEXT,
    notes               TEXT,
    erstellt_am         TEXT NOT NULL DEFAULT (datetime('now'))
);

CREATE INDEX IF NOT EXISTS idx_variation_cost_impacts_variation
    ON variation_cost_impacts(variation_id);

CREATE TABLE IF NOT EXISTS variation_time_impacts (
    id                  TEXT PRIMARY KEY NOT NULL,
    variation_id        TEXT NOT NULL,
    activity_id         TEXT,
    description         TEXT NOT NULL,
    delay_days          INTEGER NOT NULL DEFAULT 0,
    revised_completion_date TEXT,
    justification       TEXT,
    notes               TEXT,
    erstellt_am         TEXT NOT NULL DEFAULT (datetime('now'))
);

CREATE INDEX IF NOT EXISTS idx_variation_time_impacts_variation
    ON variation_time_impacts(variation_id);

-- ===== Claims =====
CREATE TABLE IF NOT EXISTS contract_claims (
    id                  TEXT PRIMARY KEY NOT NULL,
    unternehmen_id      TEXT NOT NULL,
    contract_id         TEXT NOT NULL,
    variation_id        TEXT,
    claim_number        TEXT,
    title               TEXT NOT NULL,
    claim_type          TEXT NOT NULL DEFAULT 'delay',
    description         TEXT,
    claimed_amount      REAL NOT NULL DEFAULT 0,
    entitlement_basis   TEXT,
    clause_reference    TEXT,
    notified_date       TEXT,
    submitted_date      TEXT,
    determined_amount   REAL DEFAULT 0,
    settlement_amount   REAL DEFAULT 0,
    settled_date        TEXT,
    status              TEXT NOT NULL DEFAULT 'draft',
    rejection_reason    TEXT,
    notes               TEXT,
    erstellt_am         TEXT NOT NULL DEFAULT (datetime('now')),
    aktualisiert_am     TEXT NOT NULL DEFAULT (datetime('now'))
);

CREATE INDEX IF NOT EXISTS idx_contract_claims_contract
    ON contract_claims(contract_id);
CREATE INDEX IF NOT EXISTS idx_contract_claims_status
    ON contract_claims(status);

CREATE TABLE IF NOT EXISTS claim_evidence (
    id                  TEXT PRIMARY KEY NOT NULL,
    claim_id            TEXT NOT NULL,
    evidence_type       TEXT NOT NULL,
    description         TEXT,
    file_path           TEXT,
    submitted_by        TEXT,
    submitted_at        TEXT NOT NULL DEFAULT (datetime('now')),
    notes               TEXT,
    erstellt_am         TEXT NOT NULL DEFAULT (datetime('now'))
);

CREATE INDEX IF NOT EXISTS idx_claim_evidence_claim
    ON claim_evidence(claim_id);

-- ===== Notices + Correspondence =====
CREATE TABLE IF NOT EXISTS contract_notices (
    id                  TEXT PRIMARY KEY NOT NULL,
    unternehmen_id      TEXT NOT NULL,
    contract_id         TEXT NOT NULL,
    notice_type         TEXT NOT NULL,
    notice_number       TEXT,
    subject             TEXT NOT NULL,
    body                TEXT,
    sent_by             TEXT NOT NULL,
    sent_date           TEXT NOT NULL DEFAULT (datetime('now')),
    received_by         TEXT,
    received_date       TEXT,
    response_required   INTEGER NOT NULL DEFAULT 0,
    response_due_date   TEXT,
    responded_date      TEXT,
    status              TEXT NOT NULL DEFAULT 'sent',
    erstellt_am         TEXT NOT NULL DEFAULT (datetime('now'))
);

CREATE INDEX IF NOT EXISTS idx_contract_notices_contract
    ON contract_notices(contract_id);
CREATE INDEX IF NOT EXISTS idx_contract_notices_type
    ON contract_notices(notice_type);

CREATE TABLE IF NOT EXISTS contract_correspondence (
    id                  TEXT PRIMARY KEY NOT NULL,
    unternehmen_id      TEXT NOT NULL,
    contract_id         TEXT NOT NULL,
    correspondence_type TEXT NOT NULL,
    reference_number    TEXT,
    subject             TEXT NOT NULL,
    sender              TEXT NOT NULL,
    recipient           TEXT NOT NULL,
    direction           TEXT NOT NULL DEFAULT 'incoming',
    sent_date           TEXT,
    received_date       TEXT,
    linked_notice_id    TEXT,
    linked_variation_id TEXT,
    linked_claim_id     TEXT,
    status              TEXT NOT NULL DEFAULT 'received',
    erstellt_am         TEXT NOT NULL DEFAULT (datetime('now'))
);

CREATE INDEX IF NOT EXISTS idx_contract_correspondence_contract
    ON contract_correspondence(contract_id);

-- ===== Reviews + Closeout =====
CREATE TABLE IF NOT EXISTS contract_reviews (
    id                  TEXT PRIMARY KEY NOT NULL,
    unternehmen_id      TEXT NOT NULL,
    contract_id         TEXT NOT NULL,
    reviewed_by         TEXT NOT NULL,
    rolle               TEXT NOT NULL DEFAULT 'contract_administrator',
    decision            TEXT NOT NULL DEFAULT 'no_action',
    comments            TEXT,
    reviewed_am         TEXT NOT NULL DEFAULT (datetime('now')),
    erstellt_am         TEXT NOT NULL DEFAULT (datetime('now'))
);

CREATE INDEX IF NOT EXISTS idx_contract_reviews_contract
    ON contract_reviews(contract_id);
