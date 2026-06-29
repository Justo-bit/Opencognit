-- Migration 0094: PR-MDO-2 — Locations, Tax, Currency, Documents, Classifications
CREATE TABLE IF NOT EXISTS location_hierarchy (
    id TEXT PRIMARY KEY NOT NULL, unternehmen_id TEXT NOT NULL,
    code TEXT NOT NULL, name TEXT NOT NULL, parent_id TEXT,
    location_type TEXT NOT NULL DEFAULT 'zone', is_active INTEGER NOT NULL DEFAULT 1,
    erstellt_am TEXT NOT NULL DEFAULT (datetime('now'))
);
CREATE INDEX IF NOT EXISTS idx_location_hierarchy_parent ON location_hierarchy(parent_id);

CREATE TABLE IF NOT EXISTS tax_codes (
    id TEXT PRIMARY KEY NOT NULL, unternehmen_id TEXT NOT NULL,
    code TEXT NOT NULL, name TEXT NOT NULL, rate REAL NOT NULL DEFAULT 0,
    tax_type TEXT NOT NULL DEFAULT 'vat', is_active INTEGER NOT NULL DEFAULT 1,
    erstellt_am TEXT NOT NULL DEFAULT (datetime('now'))
);
CREATE INDEX IF NOT EXISTS idx_tax_codes_code ON tax_codes(code);

CREATE TABLE IF NOT EXISTS currency_rates (
    id TEXT PRIMARY KEY NOT NULL, unternehmen_id TEXT NOT NULL,
    from_currency TEXT NOT NULL, to_currency TEXT NOT NULL,
    rate REAL NOT NULL, effective_date TEXT NOT NULL,
    source TEXT, is_active INTEGER NOT NULL DEFAULT 1,
    erstellt_am TEXT NOT NULL DEFAULT (datetime('now'))
);
CREATE INDEX IF NOT EXISTS idx_currency_rates_effective ON currency_rates(effective_date);

CREATE TABLE IF NOT EXISTS document_types (
    id TEXT PRIMARY KEY NOT NULL, unternehmen_id TEXT NOT NULL,
    type_code TEXT NOT NULL, type_name TEXT NOT NULL,
    category TEXT, required_for TEXT,
    is_active INTEGER NOT NULL DEFAULT 1,
    erstellt_am TEXT NOT NULL DEFAULT (datetime('now'))
);
CREATE INDEX IF NOT EXISTS idx_document_types_code ON document_types(type_code);

CREATE TABLE IF NOT EXISTS work_classifications (
    id TEXT PRIMARY KEY NOT NULL, unternehmen_id TEXT NOT NULL,
    class_code TEXT NOT NULL, class_name TEXT NOT NULL,
    trade TEXT, description TEXT,
    is_active INTEGER NOT NULL DEFAULT 1,
    erstellt_am TEXT NOT NULL DEFAULT (datetime('now'))
);
CREATE INDEX IF NOT EXISTS idx_work_classifications_code ON work_classifications(class_code);
