-- Ensure real-time events carry the full row data for better state merging
ALTER TABLE games REPLICA IDENTITY FULL;
ALTER TABLE players REPLICA IDENTITY FULL;
ALTER TABLE game_cards REPLICA IDENTITY FULL;
ALTER TABLE game_tiles REPLICA IDENTITY FULL;
