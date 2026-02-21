-- Add missing phases to the game_phase enum
ALTER TYPE game_phase ADD VALUE IF NOT EXISTS 'WITNESS_IDENTIFICATION';
ALTER TYPE game_phase ADD VALUE IF NOT EXISTS 'SCENE_SELECTION';
-- Removed VOTING as it is not used in Deception
