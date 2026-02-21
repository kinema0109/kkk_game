-- Function to cleanup old game chats
-- Deletes chat messages that are older than 1 day to save database storage.

CREATE OR REPLACE FUNCTION cleanup_old_chats()
RETURNS void AS $$
BEGIN
    DELETE FROM public.game_chats
    WHERE created_at < NOW() - INTERVAL '1 day';
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Provide a comment explaining usage
COMMENT ON FUNCTION public.cleanup_old_chats IS 'Deletes game chats older than 1 day to reduce DB size';

-- Note: To execute this function automatically, you can use pg_cron if enabled on your Supabase project:
-- SELECT cron.schedule(
--   'cleanup-old-chats',      -- name of the cron job
--   '0 0 * * *',              -- schedule (runs everyday at midnight)
--   $$SELECT cleanup_old_chats()$$
-- );
