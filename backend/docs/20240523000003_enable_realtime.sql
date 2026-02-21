-- Enable Realtime for the key tables
ALTER PUBLICATION supabase_realtime ADD TABLE games;
ALTER PUBLICATION supabase_realtime ADD TABLE players;
ALTER PUBLICATION supabase_realtime ADD TABLE game_cards;
ALTER PUBLICATION supabase_realtime ADD TABLE game_tiles;
