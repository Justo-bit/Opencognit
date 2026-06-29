-- Migration 0093: PR-MDO-1 — UoM, Materials, Equipment Types, Skills
CREATE TABLE IF NOT EXISTS units_of_measure (
    id TEXT PRIMARY KEY NOT NULL, unternehmen_id TEXT NOT NULL,
    code TEXT NOT NULL, name TEXT NOT NULL, category TEXT,
    base_unit_id TEXT, conversion_factor REAL DEFAULT 1,
    is_active INTEGER NOT NULL DEFAULT 1,
    erstellt_am TEXT NOT NULL DEFAULT (datetime('now'))
);
CREATE INDEX IF NOT EXISTS idx_uom_code ON units_of_measure(code);

CREATE TABLE IF NOT EXISTS material_categories (
    id TEXT PRIMARY KEY NOT NULL, unternehmen_id TEXT NOT NULL,
    category_code TEXT NOT NULL, category_name TEXT NOT NULL,
    parent_id TEXT, is_active INTEGER NOT NULL DEFAULT 1,
    erstellt_am TEXT NOT NULL DEFAULT (datetime('now'))
);
CREATE INDEX IF NOT EXISTS idx_material_categories_code ON material_categories(category_code);

CREATE TABLE IF NOT EXISTS material_catalog (
    id TEXT PRIMARY KEY NOT NULL, unternehmen_id TEXT NOT NULL,
    material_code TEXT NOT NULL, material_name TEXT NOT NULL,
    category_id TEXT, uom_id TEXT,
    description TEXT, standard_rate REAL, is_active INTEGER NOT NULL DEFAULT 1,
    erstellt_am TEXT NOT NULL DEFAULT (datetime('now'))
);
CREATE INDEX IF NOT EXISTS idx_material_catalog_code ON material_catalog(material_code);

CREATE TABLE IF NOT EXISTS equipment_types (
    id TEXT PRIMARY KEY NOT NULL, unternehmen_id TEXT NOT NULL,
    type_code TEXT NOT NULL, type_name TEXT NOT NULL,
    category TEXT, default_uom_id TEXT,
    fuel_type TEXT, is_active INTEGER NOT NULL DEFAULT 1,
    erstellt_am TEXT NOT NULL DEFAULT (datetime('now'))
);
CREATE INDEX IF NOT EXISTS idx_equipment_types_code ON equipment_types(type_code);

CREATE TABLE IF NOT EXISTS skill_catalog (
    id TEXT PRIMARY KEY NOT NULL, unternehmen_id TEXT NOT NULL,
    skill_code TEXT NOT NULL, skill_name TEXT NOT NULL,
    trade TEXT, category TEXT,
    is_active INTEGER NOT NULL DEFAULT 1,
    erstellt_am TEXT NOT NULL DEFAULT (datetime('now'))
);
CREATE INDEX IF NOT EXISTS idx_skill_catalog_code ON skill_catalog(skill_code);
