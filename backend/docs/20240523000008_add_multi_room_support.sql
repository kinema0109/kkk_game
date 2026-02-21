-- Add host_id, name, and is_public to games table
ALTER TABLE games
ADD COLUMN host_id UUID, -- We will link this to auth.users.id
ADD COLUMN name TEXT,
ADD COLUMN is_public BOOLEAN DEFAULT TRUE;

-- Update RLS policies to allow host to update/delete their game
CREATE POLICY "Host can update their game" ON games
    FOR UPDATE
    USING (auth.uid() = host_id);

CREATE POLICY "Host can delete their game" ON games
    FOR DELETE
    USING (auth.uid() = host_id);
