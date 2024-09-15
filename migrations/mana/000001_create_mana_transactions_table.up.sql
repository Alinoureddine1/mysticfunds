CREATE TABLE IF NOT EXISTS mana_transactions (
    id SERIAL PRIMARY KEY,
    from_wizard_id INTEGER NOT NULL,
    to_wizard_id INTEGER NOT NULL,
    amount BIGINT NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_mana_transactions_from_wizard ON mana_transactions(from_wizard_id);
CREATE INDEX idx_mana_transactions_to_wizard ON mana_transactions(to_wizard_id);