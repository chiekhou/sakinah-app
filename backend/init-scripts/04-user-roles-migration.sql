-- Migration : Système d'authentification multi-rôles
-- Ajoute les rôles, vérification email, profils, consentement parental

-- ========================================
-- 1. MISE À JOUR DE LA TABLE USERS
-- ========================================

-- Ajouter les nouvelles colonnes
ALTER TABLE users ADD COLUMN IF NOT EXISTS role VARCHAR(20) NOT NULL DEFAULT 'USER' 
    CHECK (role IN ('USER', 'EDUCATEUR', 'PSYCHOLOGUE', 'INTERVENANT', 'ADMIN'));

ALTER TABLE users ADD COLUMN IF NOT EXISTS is_email_verified BOOLEAN DEFAULT FALSE;
ALTER TABLE users ADD COLUMN IF NOT EXISTS email_verification_token VARCHAR(255);
ALTER TABLE users ADD COLUMN IF NOT EXISTS email_verification_expires TIMESTAMP;

ALTER TABLE users ADD COLUMN IF NOT EXISTS reset_password_token VARCHAR(255);
ALTER TABLE users ADD COLUMN IF NOT EXISTS reset_password_expires TIMESTAMP;

ALTER TABLE users ADD COLUMN IF NOT EXISTS status VARCHAR(20) NOT NULL DEFAULT 'PENDING'
    CHECK (status IN ('PENDING', 'ACTIVE', 'SUSPENDED', 'REJECTED'));

ALTER TABLE users ADD COLUMN IF NOT EXISTS pseudo VARCHAR(50) UNIQUE;
ALTER TABLE users ADD COLUMN IF NOT EXISTS avatar_url VARCHAR(500);
ALTER TABLE users ADD COLUMN IF NOT EXISTS bio TEXT;

ALTER TABLE users ADD COLUMN IF NOT EXISTS is_minor BOOLEAN DEFAULT FALSE;
ALTER TABLE users ADD COLUMN IF NOT EXISTS parent_id UUID REFERENCES users(id);

-- Pour les professionnels
ALTER TABLE users ADD COLUMN IF NOT EXISTS professional_title VARCHAR(100);
ALTER TABLE users ADD COLUMN IF NOT EXISTS diploma_url VARCHAR(500);
ALTER TABLE users ADD COLUMN IF NOT EXISTS verification_status VARCHAR(20) DEFAULT 'PENDING'
    CHECK (verification_status IN ('PENDING', 'VERIFIED', 'REJECTED'));
ALTER TABLE users ADD COLUMN IF NOT EXISTS verified_at TIMESTAMP;
ALTER TABLE users ADD COLUMN IF NOT EXISTS verified_by UUID REFERENCES users(id);

-- Statistiques
ALTER TABLE users ADD COLUMN IF NOT EXISTS last_active TIMESTAMP;
ALTER TABLE users ADD COLUMN IF NOT EXISTS login_count INTEGER DEFAULT 0;

-- Préférences de notification
ALTER TABLE users ADD COLUMN IF NOT EXISTS notification_preferences JSONB DEFAULT '{
    "email_notifications": true,
    "push_notifications": true,
    "new_message": true,
    "new_testimonial": true
}'::jsonb;

-- Index pour performance
CREATE INDEX IF NOT EXISTS idx_users_role ON users(role);
CREATE INDEX IF NOT EXISTS idx_users_status ON users(status);
CREATE INDEX IF NOT EXISTS idx_users_pseudo ON users(pseudo);
CREATE INDEX IF NOT EXISTS idx_users_email_verified ON users(is_email_verified);
CREATE INDEX IF NOT EXISTS idx_users_parent_id ON users(parent_id);

-- ========================================
-- 2. TABLE DES TÉMOIGNAGES
-- ========================================

CREATE TABLE IF NOT EXISTS testimonials (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    content TEXT NOT NULL,
    mood_level INTEGER CHECK (mood_level >= 1 AND mood_level <= 7),
    is_anonymous BOOLEAN DEFAULT TRUE,
    
    -- Modération
    status VARCHAR(20) NOT NULL DEFAULT 'PENDING' 
        CHECK (status IN ('PENDING', 'APPROVED', 'REJECTED')),
    moderated_by UUID REFERENCES users(id),
    moderated_at TIMESTAMP,
    moderation_note TEXT,
    
    -- Engagement
    likes_count INTEGER DEFAULT 0,
    comments_count INTEGER DEFAULT 0,
    reports_count INTEGER DEFAULT 0,
    
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_testimonials_user_id ON testimonials(user_id);
CREATE INDEX IF NOT EXISTS idx_testimonials_status ON testimonials(status);
CREATE INDEX IF NOT EXISTS idx_testimonials_created_at ON testimonials(created_at DESC);

-- ========================================
-- 3. TABLE DES LIKES
-- ========================================

CREATE TABLE IF NOT EXISTS testimonial_likes (
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    testimonial_id UUID NOT NULL REFERENCES testimonials(id) ON DELETE CASCADE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (user_id, testimonial_id)
);

CREATE INDEX IF NOT EXISTS idx_testimonial_likes_testimonial ON testimonial_likes(testimonial_id);

-- ========================================
-- 4. TABLE DES COMMENTAIRES
-- ========================================

CREATE TABLE IF NOT EXISTS testimonial_comments (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    testimonial_id UUID NOT NULL REFERENCES testimonials(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    content TEXT NOT NULL,
    
    -- Modération
    status VARCHAR(20) NOT NULL DEFAULT 'APPROVED'
        CHECK (status IN ('PENDING', 'APPROVED', 'REJECTED')),
    moderated_by UUID REFERENCES users(id),
    moderated_at TIMESTAMP,
    
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_comments_testimonial ON testimonial_comments(testimonial_id);
CREATE INDEX IF NOT EXISTS idx_comments_user ON testimonial_comments(user_id);
CREATE INDEX IF NOT EXISTS idx_comments_status ON testimonial_comments(status);

-- ========================================
-- 5. TABLE DES SIGNALEMENTS
-- ========================================

CREATE TABLE IF NOT EXISTS reports (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    reporter_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    reported_type VARCHAR(20) NOT NULL CHECK (reported_type IN ('TESTIMONIAL', 'COMMENT', 'USER', 'MESSAGE')),
    reported_id UUID NOT NULL,
    reason VARCHAR(50) NOT NULL CHECK (reason IN (
        'INAPPROPRIATE_CONTENT',
        'HARASSMENT',
        'SPAM',
        'VIOLENCE',
        'HATE_SPEECH',
        'FALSE_INFORMATION',
        'OTHER'
    )),
    description TEXT,
    
    -- Traitement
    status VARCHAR(20) NOT NULL DEFAULT 'PENDING'
        CHECK (status IN ('PENDING', 'REVIEWED', 'RESOLVED', 'DISMISSED')),
    handled_by UUID REFERENCES users(id),
    handled_at TIMESTAMP,
    action_taken TEXT,
    
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_reports_status ON reports(status);
CREATE INDEX IF NOT EXISTS idx_reports_reported_type ON reports(reported_type, reported_id);
CREATE INDEX IF NOT EXISTS idx_reports_reporter ON reports(reporter_id);

-- ========================================
-- 6. TABLE DES ROOMS (Pour Phase 3-4)
-- ========================================

CREATE TABLE IF NOT EXISTS chat_rooms (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(100),
    description TEXT,
    room_type VARCHAR(20) NOT NULL DEFAULT 'PRIVATE'
        CHECK (room_type IN ('PRIVATE', 'GROUP', 'SUPPORT')),
    
    created_by UUID NOT NULL REFERENCES users(id),
    is_active BOOLEAN DEFAULT TRUE,
    
    -- Modération
    is_moderated BOOLEAN DEFAULT TRUE,
    moderator_id UUID REFERENCES users(id),
    
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_rooms_created_by ON chat_rooms(created_by);
CREATE INDEX IF NOT EXISTS idx_rooms_type ON chat_rooms(room_type);

-- ========================================
-- 7. TABLE DES MEMBRES DE ROOM
-- ========================================

CREATE TABLE IF NOT EXISTS room_members (
    room_id UUID NOT NULL REFERENCES chat_rooms(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    role VARCHAR(20) DEFAULT 'MEMBER' CHECK (role IN ('ADMIN', 'MODERATOR', 'MEMBER')),
    joined_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    last_read_at TIMESTAMP,
    PRIMARY KEY (room_id, user_id)
);

CREATE INDEX IF NOT EXISTS idx_room_members_user ON room_members(user_id);

-- ========================================
-- 8. TABLE DES MESSAGES DE ROOM
-- ========================================

CREATE TABLE IF NOT EXISTS room_messages (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    room_id UUID NOT NULL REFERENCES chat_rooms(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    content TEXT NOT NULL,
    
    -- Modération IA
    is_flagged BOOLEAN DEFAULT FALSE,
    flag_reason TEXT,
    moderation_score JSONB, -- Scores de l'IA de modération
    
    -- Statut
    is_deleted BOOLEAN DEFAULT FALSE,
    deleted_by UUID REFERENCES users(id),
    deleted_at TIMESTAMP,
    
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_room_messages_room ON room_messages(room_id, created_at);
CREATE INDEX IF NOT EXISTS idx_room_messages_user ON room_messages(user_id);
CREATE INDEX IF NOT EXISTS idx_room_messages_flagged ON room_messages(is_flagged) WHERE is_flagged = TRUE;

-- ========================================
-- 9. TABLE DE CONSENTEMENT PARENTAL
-- ========================================

CREATE TABLE IF NOT EXISTS parental_consents (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    child_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    parent_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    
    consent_given BOOLEAN NOT NULL,
    consent_text TEXT NOT NULL,
    ip_address VARCHAR(45),
    
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    UNIQUE(child_id, parent_id)
);

CREATE INDEX IF NOT EXISTS idx_parental_consents_child ON parental_consents(child_id);
CREATE INDEX IF NOT EXISTS idx_parental_consents_parent ON parental_consents(parent_id);

-- ========================================
-- 10. TRIGGERS POUR UPDATED_AT
-- ========================================

-- Trigger pour users
DROP TRIGGER IF EXISTS update_users_updated_at ON users;
CREATE TRIGGER update_users_updated_at
    BEFORE UPDATE ON users
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- Trigger pour testimonials
DROP TRIGGER IF EXISTS update_testimonials_updated_at ON testimonials;
CREATE TRIGGER update_testimonials_updated_at
    BEFORE UPDATE ON testimonials
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- Trigger pour chat_rooms
DROP TRIGGER IF EXISTS update_chat_rooms_updated_at ON chat_rooms;
CREATE TRIGGER update_chat_rooms_updated_at
    BEFORE UPDATE ON chat_rooms
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- ========================================
-- 11. FONCTIONS UTILES
-- ========================================

-- Fonction pour générer un pseudo anonyme unique
CREATE OR REPLACE FUNCTION generate_anonymous_pseudo()
RETURNS VARCHAR(50) AS $$
DECLARE
    adjectives TEXT[] := ARRAY['Brave', 'Calme', 'Joyeux', 'Serein', 'Fort', 'Doux', 'Sage', 'Libre', 'Vif', 'Zen'];
    nouns TEXT[] := ARRAY['Papillon', 'Océan', 'Étoile', 'Nuage', 'Arbre', 'Lune', 'Soleil', 'Vent', 'Fleur', 'Oiseau'];
    new_pseudo VARCHAR(50);
    counter INTEGER := 0;
BEGIN
    LOOP
        new_pseudo := adjectives[1 + floor(random() * array_length(adjectives, 1))] || 
                     nouns[1 + floor(random() * array_length(nouns, 1))] || 
                     floor(random() * 1000)::TEXT;
        
        -- Vérifier si le pseudo existe déjà
        IF NOT EXISTS (SELECT 1 FROM users WHERE pseudo = new_pseudo) THEN
            RETURN new_pseudo;
        END IF;
        
        counter := counter + 1;
        IF counter > 100 THEN
            -- Fallback si on ne trouve pas de pseudo unique après 100 essais
            RETURN 'Anonyme' || uuid_generate_v4()::TEXT;
        END IF;
    END LOOP;
END;
$$ LANGUAGE plpgsql;

-- ========================================
-- 12. DONNÉES DE TEST - ADMIN
-- ========================================

-- Créer un compte admin par défaut (mot de passe: Admin123!)
INSERT INTO users (
    id,
    username,
    email,
    password_hash,
    age_range,
    role,
    status,
    is_email_verified,
    pseudo
) VALUES (
    uuid_generate_v4(),
    'admin',
    'admin@sakinah.app',
    '$2b$10$rOj5qVKzYzKkYxKkYxKkYuJ8YxKkYxKkYxKkYxKkYxKkYxKkYxKkYu', -- Hash de "Admin123!"
    '25+',
    'ADMIN',
    'ACTIVE',
    TRUE,
    'AdminSakinah'
) ON CONFLICT (email) DO NOTHING;

-- Message de confirmation
SELECT '✅ Migration terminée avec succès !' AS message;
SELECT 'Nouveaux rôles : USER, EDUCATEUR, PSYCHOLOGUE, INTERVENANT, ADMIN' AS roles;
SELECT 'Nouvelles tables : testimonials, reports, chat_rooms, room_messages, parental_consents' AS tables;
SELECT '🔐 Compte admin créé : admin@sakinah.app / Admin123!' AS admin_account;