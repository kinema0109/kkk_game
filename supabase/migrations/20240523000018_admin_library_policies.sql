-- Enable full access on library_cards and library_tiles for Admin operations
CREATE POLICY "Public enable all access on library_cards" ON library_cards FOR ALL USING (true);
CREATE POLICY "Public enable all access on library_tiles" ON library_tiles FOR ALL USING (true);
