-- Script d'initialisation pour PostgreSQL
-- Ce script crée les tables de base pour l'application

-- Extension pour UUID
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Table des utilisateurs
CREATE TABLE IF NOT EXISTS users (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    username VARCHAR(50) UNIQUE NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    date_of_birth DATE,
    age_range VARCHAR(10) NOT NULL CHECK (age_range IN ('6-12', '13-17', '18-25', '25+')),
    accessibility_settings JSONB DEFAULT '{"font_size": "medium", "high_contrast": false, "screen_reader": false, "simplified_language": false}'::jsonb,
    last_login TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Table des entrées d'humeur
CREATE TABLE IF NOT EXISTS mood_entries (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4 (),
    user_id UUID NOT NULL REFERENCES users (id) ON DELETE CASCADE,
    mood_level INTEGER NOT NULL CHECK (
        mood_level >= 1
        AND mood_level <= 7
    ),
    note TEXT,
    timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Index pour améliorer les performances
CREATE INDEX IF NOT EXISTS idx_mood_entries_user_id ON mood_entries (user_id);

CREATE INDEX IF NOT EXISTS idx_mood_entries_timestamp ON mood_entries (timestamp);

CREATE INDEX IF NOT EXISTS idx_mood_entries_user_timestamp ON mood_entries (user_id, timestamp);

-- Table des quiz

CREATE TYPE difficultyEnum AS ENUM('facile','moyen','difficile');

CREATE TABLE IF NOT EXISTS quizzes (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4 (),
    title VARCHAR(255) NOT NULL,
    description TEXT,
    theme VARCHAR(100) NOT NULL,
    age_target_min INTEGER,
    age_target_max INTEGER,
    questions JSONB NOT NULL,
    difficulty difficultyEnum DEFAULT NULL,
    duration_minutes INTEGER,
    mood_tags INTEGER[] DEFAULT ARRAY[]::INTEGER[],
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Table des résultats de quiz
CREATE TABLE IF NOT EXISTS quiz_results (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4 (),
    user_id UUID NOT NULL REFERENCES users (id) ON DELETE CASCADE,
    quiz_id UUID NOT NULL REFERENCES quizzes (id) ON DELETE CASCADE,
    score INTEGER NOT NULL,
    answers JSONB,
    completed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Index pour les quiz
CREATE INDEX IF NOT EXISTS idx_quiz_results_user_id ON quiz_results (user_id);

CREATE INDEX IF NOT EXISTS idx_quiz_results_quiz_id ON quiz_results (quiz_id);

-- Table des articles
CREATE TABLE IF NOT EXISTS articles (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    title VARCHAR(255) NOT NULL,
    content TEXT NOT NULL,
    theme VARCHAR(100) NOT NULL,
    summary VARCHAR(500) NOT NULL,
    mood_tags INTEGER[] DEFAULT ARRAY[]::INTEGER[],
    age_target_min INTEGER,
    age_target_max INTEGER,
    reading_time_minutes INTEGER,
    media_url VARCHAR(500),
    is_featured BOOLEAN  DEFAULT false,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Index pour les articles
CREATE INDEX IF NOT EXISTS idx_articles_theme ON articles (theme);

CREATE INDEX IF NOT EXISTS idx_articles_mood_tags ON articles USING GIN (mood_tags);

-- Table des scénarios (mises en situation)
CREATE TABLE IF NOT EXISTS scenarios (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4 (),
    title VARCHAR(255) NOT NULL,
    description TEXT,
    theme VARCHAR(100) NOT NULL,
    steps JSONB NOT NULL,
    age_target_min INTEGER,
    age_target_max INTEGER,
    duration_minutes INTEGER,
    mood_tags INTEGER[] DEFAULT ARRAY[]::INTEGER[],
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Table des badges
CREATE TABLE IF NOT EXISTS badges (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4 (),
    name VARCHAR(100) NOT NULL,
    description TEXT,
    icon_url VARCHAR(500),
    unlock_criteria JSONB NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Table de liaison utilisateurs-badges
CREATE TABLE IF NOT EXISTS user_badges (
    user_id UUID NOT NULL REFERENCES users (id) ON DELETE CASCADE,
    badge_id UUID NOT NULL REFERENCES badges (id) ON DELETE CASCADE,
    unlocked_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (user_id, badge_id)
);

-- Index pour les badges
CREATE INDEX IF NOT EXISTS idx_user_badges_user_id ON user_badges (user_id);

-- Trigger pour mettre à jour updated_at automatiquement
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ language 'plpgsql';

CREATE TRIGGER update_users_updated_at BEFORE UPDATE ON users
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_quizzes_updated_at BEFORE UPDATE ON quizzes
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_articles_updated_at BEFORE UPDATE ON articles
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_scenarios_updated_at BEFORE UPDATE ON scenarios
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Données de test (optionnel)
-- Insérer quelques badges par défaut
INSERT INTO
    badges (
        name,
        description,
        icon_url,
        unlock_criteria
    )
VALUES (
        'Premier Pas',
        'Tu as créé ton compte !',
        '/badges/first_step.png',
        '{"action": "signup"}'
    ),
    (
        'Explorateur d''émotions',
        'Tu as complété 5 quiz',
        '/badges/emotion_explorer.png',
        '{"action": "quiz_completed", "count": 5}'
    ),
    (
        'Fidèle Compagnon',
        'Tu es revenu 7 jours d''affilée',
        '/badges/streak_7.png',
        '{"action": "streak", "days": 7}'
    ),
    (
        'Gardien du Bien-être',
        'Tu as utilisé l''app pendant 30 jours',
        '/badges/wellbeing_guardian.png',
        '{"action": "active_days", "count": 30}'
    ) ON CONFLICT DO NOTHING;

-- Message de confirmation
SELECT 'Base de données initialisée avec succès !' AS message;