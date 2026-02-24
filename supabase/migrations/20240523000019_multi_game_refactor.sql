-- Migration: Multi-Game Database Refactor (JSONB Metadata)
-- Optimized to reduce table bloat and support multiple game types.

-- 1. Add metadata and game_type columns
ALTER TABLE games ADD COLUMN IF NOT EXISTS metadata JSONB DEFAULT '{}'::jsonb;
ALTER TABLE games ADD COLUMN IF NOT EXISTS game_type TEXT DEFAULT 'deception';
ALTER TABLE players ADD COLUMN IF NOT EXISTS metadata JSONB DEFAULT '{}'::jsonb;

-- 2. Migrate existing game data to metadata
UPDATE games
SET metadata = jsonb_build_object(
    'round', round,
    'winner', winner,
    'solution_murderer_id', solution_murderer_id,
    'solution_means_id', solution_means_id,
    'solution_clue_id', solution_clue_id
)
WHERE round IS NOT NULL OR winner IS NOT NULL OR solution_murderer_id IS NOT NULL;

-- 3. Migrate existing player data to metadata
UPDATE players
SET metadata = jsonb_build_object(
    'role', role,
    'has_badge', has_badge,
    'seat_index', seat_index
)
WHERE role IS NOT NULL OR has_badge IS NOT NULL;

-- 4. Drop Deception-specific columns from games
ALTER TABLE games DROP COLUMN IF EXISTS round;
ALTER TABLE games DROP COLUMN IF EXISTS winner;
ALTER TABLE games DROP COLUMN IF EXISTS solution_murderer_id;
ALTER TABLE games DROP COLUMN IF EXISTS solution_means_id;
ALTER TABLE games DROP COLUMN IF EXISTS solution_clue_id;

-- 5. Drop Deception-specific columns from players
ALTER TABLE players DROP COLUMN IF EXISTS role;
ALTER TABLE players DROP COLUMN IF EXISTS has_badge;
ALTER TABLE players DROP COLUMN IF EXISTS seat_index;

-- 6. Generalize Game Status
-- Convert status column from game_phase Enum to TEXT to support any game's phases
ALTER TABLE games ALTER COLUMN status DROP DEFAULT;
ALTER TABLE games ALTER COLUMN status TYPE TEXT USING status::TEXT;
ALTER TABLE games ALTER COLUMN status SET DEFAULT 'LOBBY';

-- Note: We keep the enums user_role, card_type, etc. in the DB for now
-- as they might be useful for Deception-specific library tables,
-- but the main games/players tables are now generic.
