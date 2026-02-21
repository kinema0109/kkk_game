-- Function to cleanup stale lobbies
-- Deletes games that are in 'LOBBY' status and haven't been updated for 60 minutes.

CREATE OR REPLACE FUNCTION cleanup_stale_lobbies()
RETURNS void AS $$
BEGIN
    DELETE FROM games
    WHERE status = 'LOBBY'
    AND created_at < NOW() - INTERVAL '60 minutes';
END;
$$ LANGUAGE plpgsql;

-- If pg_cron is available (requires extension on Supabase), schedule it.
-- We wrap this in a DO block to avoid errors if pg_cron is not available.
-- Note: In many Supabase free tiers, pg_cron might not be enabled or user might not have permission.
-- In that case, this part will be skipped or error out safely if we handle it right, 
-- but 'create extension' inside DO block is tricky.
-- We will just define the function. The user can invoke it manually or set up a cron job via UI.

COMMENT ON FUNCTION cleanup_stale_lobbies IS 'Deletes lobbies older than 60 minutes';
