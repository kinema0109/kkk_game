-- Add image_url to library_cards
ALTER TABLE library_cards ADD COLUMN IF NOT EXISTS image_url TEXT;

-- Create a storage bucket for 'game-assets'
INSERT INTO storage.buckets (id, name, public) 
VALUES ('game-assets', 'game-assets', true)
ON CONFLICT (id) DO NOTHING;

-- Policy to allow public read access to game-assets
create policy "Public Access"
on storage.objects for select
using ( bucket_id = 'game-assets' );

-- Policy to allow authenticated uploads to game-assets
-- (Adjust strictly if needed, e.g., only admins)
-- For now, allowing authenticated users (which includes anon if anon key is used, but usually requires user_id)
-- But wait, our app uses ANON key for most things.
-- If we want the admin page to upload, we need a policy for it.
-- Let's allow public uploads for now to simplify, or check auth.
-- The admin page checks `localStorage` or `cookie` for admin status but Supabase RLS is separate.
-- If we assume the user is just using the anon key without true Auth:
create policy "Public Upload"
on storage.objects for insert
with check ( bucket_id = 'game-assets' );

-- Allow update/delete for ease of development
create policy "Public Update"
on storage.objects for update
with check ( bucket_id = 'game-assets' );

create policy "Public Delete"
on storage.objects for delete
using ( bucket_id = 'game-assets' );
