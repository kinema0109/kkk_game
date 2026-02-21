-- Create Enums
CREATE TYPE user_role AS ENUM ('FORENSIC_SCIENTIST', 'MURDERER', 'INVESTIGATOR', 'WITNESS', 'ACCOMPLICE');
CREATE TYPE game_phase AS ENUM ('LOBBY', 'SETUP', 'CRIME_SELECTION', 'INVESTIGATION', 'GAME_OVER');
CREATE TYPE card_type AS ENUM ('MEANS', 'CLUE');
CREATE TYPE tile_type AS ENUM ('CAUSE_OF_DEATH', 'LOCATION', 'SCENE');

-- Create Tables

-- 1. Library Tables (Static Data)
CREATE TABLE library_cards (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    type card_type NOT NULL,
    content TEXT NOT NULL,
    image_url TEXT,
    image_base64 TEXT -- For storing small images directly
);

CREATE TABLE library_tiles (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name TEXT NOT NULL,
    type tile_type NOT NULL,
    options JSONB NOT NULL -- Array of strings
);

-- 2. Game Instance Tables
CREATE TABLE games (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    room_code TEXT UNIQUE NOT NULL,
    status game_phase DEFAULT 'LOBBY',
    round INT DEFAULT 0,
    winner TEXT, -- 'GOOD' or 'EVIL'
    solution_murderer_id UUID, -- References users(id) or players(id) depending on auth strategy. Using UUID for now.
    solution_means_id UUID REFERENCES library_cards(id),
    solution_clue_id UUID REFERENCES library_cards(id),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE TABLE players (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    game_id UUID REFERENCES games(id) ON DELETE CASCADE,
    user_id UUID, -- Optional: Link to Supabase Auth user if logged in
    name TEXT NOT NULL,
    password TEXT, -- Simple PIN/Password for re-joining
    is_admin BOOLEAN DEFAULT FALSE,
    role user_role,
    has_badge BOOLEAN DEFAULT TRUE,
    is_online BOOLEAN DEFAULT TRUE,
    seat_index INT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE TABLE game_cards (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    game_id UUID REFERENCES games(id) ON DELETE CASCADE,
    player_id UUID REFERENCES players(id) ON DELETE CASCADE,
    card_id UUID REFERENCES library_cards(id),
    is_selected BOOLEAN DEFAULT FALSE -- Used for crime solution selection or specific gameplay mechanics
);

CREATE TABLE game_tiles (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    game_id UUID REFERENCES games(id) ON DELETE CASCADE,
    tile_id UUID REFERENCES library_tiles(id),
    selected_option_index INT, -- Index in the options array
    round_added INT DEFAULT 0, -- 0 for start, 1, 2, 3 for later
    display_order INT
);

-- RLS Policies (Simplified for development - Open access)
ALTER TABLE library_cards ENABLE ROW LEVEL SECURITY;
ALTER TABLE library_tiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE games ENABLE ROW LEVEL SECURITY;
ALTER TABLE players ENABLE ROW LEVEL SECURITY;
ALTER TABLE game_cards ENABLE ROW LEVEL SECURITY;
ALTER TABLE game_tiles ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Public read access" ON library_cards FOR SELECT USING (true);
CREATE POLICY "Public read access" ON library_tiles FOR SELECT USING (true);

-- Allow anyone to create a game and join (for now)
CREATE POLICY "Public enable all access on games" ON games FOR ALL USING (true);
CREATE POLICY "Public enable all access on players" ON players FOR ALL USING (true);
CREATE POLICY "Public enable all access on game_cards" ON game_cards FOR ALL USING (true);
CREATE POLICY "Public enable all access on game_tiles" ON game_tiles FOR ALL USING (true);


-- FUNCTIONS

CREATE OR REPLACE FUNCTION reset_game(p_game_id UUID)
RETURNS VOID AS $$
BEGIN
    -- 1. Reset Game State
    UPDATE games
    SET status = 'LOBBY',
        round = 0,
        winner = NULL,
        solution_murderer_id = NULL,
        solution_means_id = NULL,
        solution_clue_id = NULL
    WHERE id = p_game_id;

    -- 2. Clear In-Play Cards and Tiles
    DELETE FROM game_cards WHERE game_id = p_game_id;
    DELETE FROM game_tiles WHERE game_id = p_game_id;

    -- 3. Reset Players (Keep them in the room, but strip roles)
    UPDATE players
    SET role = NULL,
        has_badge = TRUE
    WHERE game_id = p_game_id;
END;
$$ LANGUAGE plpgsql;

-- SEED DATA

-- Library Tiles
INSERT INTO library_tiles (name, type, options) VALUES
('Cause of Death', 'CAUSE_OF_DEATH', '["Suffocation", "Severe Injury", "Loss of Blood", "Illness/Disease", "Poisoning"]'),
('Location of Crime', 'LOCATION', '["Living Room", "Bedroom", "Kitchen", "Bathroom", "Balcony", "Street"]'),
('Corpse Condition', 'SCENE', '["Stiff", "Decayed", "Incomplete", "Intact", "Burned"]'),
('Trace at Scene', 'SCENE', '["Fingerprint", "Footprint", "Bruise", "Blood Stain", "Body Fluid"]'),
('Social Relationship', 'SCENE', '["Relatives", "Friends", "Colleagues", "Employer/Employee", "Lovers", "Strangers"]'),
('Victim''s Outfit', 'SCENE', '["Suit", "Casual", "Uniform", "Pajamas", "Naked"]'),
('Time of Death', 'SCENE', '["Dawn", "Morning", "Noon", "Afternoon", "Evening", "Midnight"]'),
('Duration of Detection', 'SCENE', '["Instant", "Minutes", "Hours", "Days", "Weeks"]'),
('Weather', 'SCENE', '["Sunny", "Rainy", "Windy", "Foggy", "Snowy"]'),
('Motive', 'SCENE', '["Hatred", "Power", "Money", "Love", "Jealousy"]'),
('Sudden Incident', 'SCENE', '["Power Outage", "Fire", "Conflict", "Scream", "Nothing"]'),
('Weapon Build', 'SCENE', '["Sharp", "Heavy", "Small", "Long", "Mechanized"]');

-- Library Cards (Means - Red)
INSERT INTO library_cards (type, content) VALUES
('MEANS', 'Arsenic'), ('MEANS', 'Dagger'), ('MEANS', 'Rope'), ('MEANS', 'Pistol'), ('MEANS', 'Pillow'),
('MEANS', 'Brick'), ('MEANS', 'Water'), ('MEANS', 'Chemical'), ('MEANS', 'Electricity'), ('MEANS', 'Ice'),
('MEANS', 'Sculpture'), ('MEANS', 'Virus'), ('MEANS', 'Explosive'), ('MEANS', 'Candle'), ('MEANS', 'Plant');

-- Library Cards (Clues - Blue)
INSERT INTO library_cards (type, content) VALUES
('CLUE', 'Badge'), ('CLUE', 'Cigarette Butt'), ('CLUE', 'Lipstick'), ('CLUE', 'Watch'), ('CLUE', 'Hairpin'),
('CLUE', 'Ring'), ('CLUE', 'Button'), ('CLUE', 'Receipt'), ('CLUE', 'Key'), ('CLUE', 'Wallet'),
('CLUE', 'Phone'), ('CLUE', 'Diary'), ('CLUE', 'Prescription'), ('CLUE', 'Ticket'), ('CLUE', 'Glove');

