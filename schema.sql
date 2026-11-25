-- Couple lock table
CREATE TABLE IF NOT EXISTS couples (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  created_at TIMESTAMPTZ DEFAULT now(),
  user1_id UUID REFERENCES auth.users(id),
  user2_id UUID REFERENCES auth.users(id),
  status TEXT DEFAULT 'active'
);

-- Profiles table
CREATE TABLE IF NOT EXISTS profiles (
  id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  display_name TEXT NOT NULL,
  favorite_color TEXT DEFAULT '#ff4d79',
  avatar TEXT,
  updated_at TIMESTAMPTZ DEFAULT now()
);

-- Matches / Scores history table
CREATE TABLE IF NOT EXISTS matches (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  couple_id UUID REFERENCES couples(id),
  winner_id UUID REFERENCES auth.users(id),
  target_score INT DEFAULT 100,
  score_taha INT DEFAULT 0,
  score_fofat INT DEFAULT 0,
  total_rounds INT DEFAULT 1,
  ended_at TIMESTAMPTZ DEFAULT now()
);

-- RLS setup
ALTER TABLE couples ENABLE ROW LEVEL SECURITY;
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE matches ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can read their couple" ON couples
  FOR SELECT USING (auth.uid() = user1_id OR auth.uid() = user2_id);

CREATE POLICY "Couples can access match records" ON matches
  FOR ALL USING (auth.uid() IN (
    SELECT user1_id FROM couples WHERE id = couple_id
    UNION
    SELECT user2_id FROM couples WHERE id = couple_id
  ));
