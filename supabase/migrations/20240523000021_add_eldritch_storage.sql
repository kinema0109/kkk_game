-- Create a storage bucket for 'eldritch-assets'
INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types) 
VALUES ('eldritch-assets', 'eldritch-assets', true, 5242880, '{image/webp}')
ON CONFLICT (id) DO NOTHING;

-- Policy to allow public read access
CREATE POLICY "Public Read Access"
ON storage.objects FOR SELECT
USING ( bucket_id = 'eldritch-assets' );

-- Policy to allow authenticated/admin uploads
-- For efficiency in seeding, we'll allow public uploads temporarily if needed, 
-- but better to permit service role or specific auth.
-- Let's use the same pattern as game-assets for consistency if that worked.
CREATE POLICY "Public Upload"
ON storage.objects FOR INSERT
WITH CHECK ( bucket_id = 'eldritch-assets' );

CREATE POLICY "Public Update"
ON storage.objects FOR UPDATE
WITH CHECK ( bucket_id = 'eldritch-assets' );

CREATE POLICY "Public Delete"
ON storage.objects FOR DELETE
USING ( bucket_id = 'eldritch-assets' );
