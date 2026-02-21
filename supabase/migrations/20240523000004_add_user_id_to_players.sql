DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'players' AND column_name = 'user_id') THEN
        ALTER TABLE players ADD COLUMN user_id UUID REFERENCES auth.users(id);
    ELSE
        -- If it exists but doesn't have the reference, we can add it
        ALTER TABLE players DROP CONSTRAINT IF EXISTS players_user_id_fkey;
        ALTER TABLE players ADD CONSTRAINT players_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id);
    END IF;
END $$;

-- Add index for performance
CREATE INDEX IF NOT EXISTS idx_players_user_id ON players(user_id);
