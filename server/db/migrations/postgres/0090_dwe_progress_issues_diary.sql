-- Migration 0090: PR-DWE-2 — Progress, Issues, Site Diary, Reviews

CREATE TABLE IF NOT EXISTS work_progress_records (
    id SERIAL PRIMARY KEY, unternehmen_id TEXT NOT NULL, project_id TEXT NOT NULL,
    work_pack_id TEXT, activity_id TEXT, report_date TEXT NOT NULL,
    planned_pct DOUBLE PRECISION DEFAULT 0, actual_pct DOUBLE PRECISION NOT NULL DEFAULT 0,
    description TEXT, reported_by TEXT NOT NULL,
    erstellt_am TEXT NOT NULL DEFAULT (NOW())
);
CREATE INDEX IF NOT EXISTS idx_work_progress_project ON work_progress_records(project_id);

CREATE TABLE IF NOT EXISTS work_execution_issues (
    id SERIAL PRIMARY KEY, unternehmen_id TEXT NOT NULL, project_id TEXT NOT NULL,
    work_pack_id TEXT, execution_record_id TEXT,
    issue_type TEXT NOT NULL, description TEXT NOT NULL,
    severity TEXT NOT NULL DEFAULT 'medium', raised_by TEXT NOT NULL,
    resolution TEXT, resolved_by TEXT, resolved_am TEXT,
    status TEXT NOT NULL DEFAULT 'open',
    erstellt_am TEXT NOT NULL DEFAULT (NOW()), aktualisiert_am TEXT NOT NULL DEFAULT (NOW())
);
CREATE INDEX IF NOT EXISTS idx_work_execution_issues_project ON work_execution_issues(project_id);

CREATE TABLE IF NOT EXISTS site_diary_entries (
    id SERIAL PRIMARY KEY, unternehmen_id TEXT NOT NULL, project_id TEXT NOT NULL,
    diary_date TEXT NOT NULL, shift TEXT DEFAULT 'day',
    weather_am TEXT, weather_pm TEXT, temperature_min DOUBLE PRECISION, temperature_max DOUBLE PRECISION,
    work_summary TEXT NOT NULL, visitors TEXT, instructions_received TEXT,
    plant_on_site TEXT, labour_on_site TEXT, materials_received TEXT,
    incidents TEXT, delays TEXT, recorded_by TEXT NOT NULL,
    reviewed_by TEXT, erstellt_am TEXT NOT NULL DEFAULT (NOW())
);
CREATE INDEX IF NOT EXISTS idx_site_diary_project ON site_diary_entries(project_id);
CREATE INDEX IF NOT EXISTS idx_site_diary_date ON site_diary_entries(diary_date);

CREATE TABLE IF NOT EXISTS work_execution_reviews (
    id SERIAL PRIMARY KEY, unternehmen_id TEXT NOT NULL, project_id TEXT NOT NULL,
    work_pack_id TEXT, reviewed_by TEXT NOT NULL,
    rolle TEXT NOT NULL DEFAULT 'site_engineer', review_type TEXT NOT NULL DEFAULT 'daily',
    decision TEXT NOT NULL DEFAULT 'no_action', comments TEXT,
    reviewed_am TEXT NOT NULL DEFAULT (NOW()),
    erstellt_am TEXT NOT NULL DEFAULT (NOW())
);
CREATE INDEX IF NOT EXISTS idx_work_execution_reviews_project ON work_execution_reviews(project_id);

CREATE TABLE IF NOT EXISTS dwe_reviews (
    id SERIAL PRIMARY KEY, unternehmen_id TEXT NOT NULL, project_id TEXT NOT NULL,
    reviewed_by TEXT NOT NULL, rolle TEXT NOT NULL DEFAULT 'project_manager',
    review_type TEXT NOT NULL DEFAULT 'weekly', decision TEXT NOT NULL DEFAULT 'no_action',
    comments TEXT, reviewed_am TEXT NOT NULL DEFAULT (NOW()),
    erstellt_am TEXT NOT NULL DEFAULT (NOW())
);
CREATE INDEX IF NOT EXISTS idx_dwe_reviews_project ON dwe_reviews(project_id);
