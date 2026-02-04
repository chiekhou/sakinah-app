-- ========================================
-- TABLE DES NOTIFICATIONS
-- ========================================

CREATE TABLE IF NOT EXISTS notifications (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,

-- Type de notification
type VARCHAR(50) NOT NULL CHECK (
    type IN (
        'TESTIMONIAL_APPROVED',
        'TESTIMONIAL_REJECTED',
        'COMMENT_APPROVED',
        'COMMENT_REJECTED',
        'TESTIMONIAL_LIKED',
        'TESTIMONIAL_COMMENTED',
        'COMMENT_REPLIED',
        'SYSTEM_MESSAGE'
    )
),

-- Contenu
title VARCHAR(255) NOT NULL, message TEXT NOT NULL,

-- Lien vers l'entité concernée
related_type VARCHAR(50) CHECK (
    related_type IN (
        'TESTIMONIAL',
        'COMMENT',
        'USER',
        NULL
    )
),
related_id UUID,

-- Statut
is_read BOOLEAN DEFAULT FALSE, read_at TIMESTAMP,

-- Métadonnées (pour stockage flexible)
metadata JSONB,
    
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Index pour performance
CREATE INDEX IF NOT EXISTS idx_notifications_user_id ON notifications (user_id);

CREATE INDEX IF NOT EXISTS idx_notifications_user_unread ON notifications (user_id, is_read)
WHERE
    is_read = FALSE;

CREATE INDEX IF NOT EXISTS idx_notifications_type ON notifications(type);

CREATE INDEX IF NOT EXISTS idx_notifications_created_at ON notifications (created_at DESC);

-- Commentaires
COMMENT ON
TABLE notifications IS 'Notifications utilisateurs (témoignages, commentaires, likes)';

COMMENT ON COLUMN notifications.type IS 'Type de notification';

COMMENT ON COLUMN notifications.related_type IS 'Type d''entité liée (TESTIMONIAL, COMMENT, USER)';

COMMENT ON COLUMN notifications.related_id IS 'ID de l''entité liée';

COMMENT ON COLUMN notifications.metadata IS 'Données supplémentaires en JSON';

-- Message de confirmation
SELECT '✅ Table notifications créée avec succès !' AS message;