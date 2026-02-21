-- Add a unique constraint to prevent a single user from joining the same game multiple times
-- This guards against race conditions where the join API handles multiple rapid requests

ALTER TABLE public.players 
ADD CONSTRAINT unique_player_in_game UNIQUE (game_id, user_id);
