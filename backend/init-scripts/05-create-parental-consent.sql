DROP TABLE IF EXISTS parental_consents CASCADE;

CREATE TABLE parental_consents (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL,
    parent_email VARCHAR(255) NOT NULL,
    consent_given BOOLEAN DEFAULT false NOT NULL,
    consent_date TIMESTAMP,
    consent_ip VARCHAR(45),
    consent_token VARCHAR(255) UNIQUE,
    consent_token_expires TIMESTAMP,
    revoked BOOLEAN DEFAULT false NOT NULL,
    revoked_date TIMESTAMP,
    revoked_reason TEXT,
    notification_sent BOOLEAN DEFAULT false NOT NULL,
    notification_sent_date TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
    CONSTRAINT fk_parental_consents_user
        FOREIGN KEY (user_id) REFERENCES users(id)
        ON DELETE CASCADE ON UPDATE CASCADE
);

-- Index pour optimiser les recherches
CREATE INDEX IF NOT EXISTS idx_parental_consents_user_id 
    ON parental_consents(user_id);

CREATE INDEX IF NOT EXISTS idx_parental_consents_parent_email 
    ON parental_consents(parent_email);

CREATE INDEX IF NOT EXISTS idx_parental_consents_consent_token 
    ON parental_consents(consent_token);

CREATE INDEX IF NOT EXISTS idx_parental_consents_consent_status 
    ON parental_consents(consent_given, revoked);

-- Commentaires pour documentation
COMMENT ON TABLE parental_consents IS 'Consentements parentaux pour les utilisateurs mineurs (RGPD)';
COMMENT ON COLUMN parental_consents.user_id IS 'ID de l''utilisateur mineur';
COMMENT ON COLUMN parental_consents.parent_email IS 'Email du parent ou tuteur légal';
COMMENT ON COLUMN parental_consents.consent_given IS 'Le parent a-t-il donné son consentement ?';
COMMENT ON COLUMN parental_consents.consent_date IS 'Date à laquelle le consentement a été donné';
COMMENT ON COLUMN parental_consents.consent_ip IS 'Adresse IP lors du consentement (traçabilité RGPD)';
COMMENT ON COLUMN parental_consents.consent_token IS 'Token unique pour le lien de confirmation (64 caractères)';
COMMENT ON COLUMN parental_consents.consent_token_expires IS 'Date d''expiration du token (7 jours)';
COMMENT ON COLUMN parental_consents.revoked IS 'Le consentement a-t-il été révoqué ?';
COMMENT ON COLUMN parental_consents.revoked_date IS 'Date de révocation du consentement';
COMMENT ON COLUMN parental_consents.revoked_reason IS 'Raison de la révocation (optionnel)';
COMMENT ON COLUMN parental_consents.notification_sent IS 'Email de notification envoyé au parent ?';
COMMENT ON COLUMN parental_consents.notification_sent_date IS 'Date d''envoi de l''email au parent';

CREATE EXTENSION IF NOT EXISTS "pgcrypto";