-- Add missing CARD_DRAFTING phase to the game_phase enum
ALTER TYPE game_phase ADD VALUE IF NOT EXISTS 'CARD_DRAFTING';
