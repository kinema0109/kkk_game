-- Extend card_type enum for Eldritch Horror
ALTER TYPE card_type ADD VALUE IF NOT EXISTS 'INVESTIGATOR';
ALTER TYPE card_type ADD VALUE IF NOT EXISTS 'ANCIENT_ONE';
ALTER TYPE card_type ADD VALUE IF NOT EXISTS 'ENCOUNTER';
ALTER TYPE card_type ADD VALUE IF NOT EXISTS 'MONSTER';
ALTER TYPE card_type ADD VALUE IF NOT EXISTS 'CONDITION';
ALTER TYPE card_type ADD VALUE IF NOT EXISTS 'SPELL';
ALTER TYPE card_type ADD VALUE IF NOT EXISTS 'ITEM';
ALTER TABLE library_cards ADD COLUMN IF NOT EXISTS game_type TEXT DEFAULT 'deception';

-- Add metadata JSONB to store game-specific card data (stats, flavor, etc.)
ALTER TABLE library_cards ADD COLUMN IF NOT EXISTS metadata JSONB DEFAULT '{}'::jsonb;

-- Create an index on game_type for faster filtering
CREATE INDEX IF NOT EXISTS idx_library_cards_game_type ON library_cards(game_type);

-- Update existing cards to 'deception'
UPDATE library_cards SET game_type = 'deception' WHERE game_type IS NULL;
