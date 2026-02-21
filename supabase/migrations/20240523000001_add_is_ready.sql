-- Add is_ready column to players table
ALTER TABLE public.players 
ADD COLUMN IF NOT EXISTS is_ready BOOLEAN DEFAULT FALSE;

-- Allow public (or authenticated) access to library_cards
-- First drop existing policy if it exists to avoid conflicts (or just create if not exists)
DROP POLICY IF EXISTS "Allow public read access" ON public.library_cards;
DROP POLICY IF EXISTS "Allow admin insert" ON public.library_cards;

-- Create permissive policies for library_cards as requested ("ai cũng có thể sửa")
CREATE POLICY "Allow public read access" ON public.library_cards
FOR SELECT USING (true);

CREATE POLICY "Allow public insert access" ON public.library_cards
FOR INSERT WITH CHECK (true);

CREATE POLICY "Allow public update access" ON public.library_cards
FOR UPDATE USING (true);

CREATE POLICY "Allow public delete access" ON public.library_cards
FOR DELETE USING (true);
