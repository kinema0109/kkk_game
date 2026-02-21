-- Enable Realtime for game tables
-- We use a safe approach by checking if the publication exists (it should by default in Supabase)
-- If not, we create it.

DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_publication WHERE pubname = 'supabase_realtime') THEN
        CREATE PUBLICATION supabase_realtime;
    END IF;
END
$$;

-- Add tables to the publication
ALTER PUBLICATION supabase_realtime ADD TABLE games;
ALTER PUBLICATION supabase_realtime ADD TABLE players;
ALTER PUBLICATION supabase_realtime ADD TABLE game_cards;
ALTER PUBLICATION supabase_realtime ADD TABLE game_tiles;
