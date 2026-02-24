-- Add name column to library_cards
ALTER TABLE library_cards ADD COLUMN IF NOT EXISTS name TEXT;

-- For existing deception cards, we can copy content to name if it's short, but for now just leave it
-- UPDATE library_cards SET name = content WHERE game_type = 'deception';

-- Ensure we can upsert by name
-- Note: In a real production environment, you might want UNIQUE(name, game_type)
ALTER TABLE library_cards ADD CONSTRAINT library_cards_name_key UNIQUE (name);
