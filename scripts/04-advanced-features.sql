-- Tables pour les fonctionnalités avancées

-- Table pour les comptes email
CREATE TABLE IF NOT EXISTS email_accounts (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    collaborator_id UUID REFERENCES collaborators(id) NOT NULL,
    email VARCHAR(255) NOT NULL,
    provider VARCHAR(50) NOT NULL, -- gmail, outlook, etc.
    imap_host VARCHAR(255),
    imap_port INTEGER DEFAULT 993,
    smtp_host VARCHAR(255),
    smtp_port INTEGER DEFAULT 587,
    username VARCHAR(255) NOT NULL,
    password_encrypted TEXT, -- Stocké de manière sécurisée
    is_active BOOLEAN DEFAULT true,
    last_sync TIMESTAMPTZ,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Table pour les emails
CREATE TABLE IF NOT EXISTS emails (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    email_account_id UUID REFERENCES email_accounts(id),
    contact_id UUID REFERENCES contacts(id),
    collaborator_id UUID REFERENCES collaborators(id) NOT NULL,
    subject VARCHAR(500),
    body TEXT,
    from_email VARCHAR(255) NOT NULL,
    to_email VARCHAR(255) NOT NULL,
    cc_email TEXT,
    bcc_email TEXT,
    email_type VARCHAR(50) DEFAULT 'outbound', -- inbound, outbound
    status VARCHAR(50) DEFAULT 'sent', -- sent, delivered, opened, failed
    message_id VARCHAR(255),
    thread_id VARCHAR(255),
    attachments JSONB DEFAULT '[]',
    metadata JSONB DEFAULT '{}',
    sent_at TIMESTAMPTZ,
    opened_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Table pour les notifications
CREATE TABLE IF NOT EXISTS notifications (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    collaborator_id UUID REFERENCES collaborators(id) NOT NULL,
    title VARCHAR(255) NOT NULL,
    message TEXT NOT NULL,
    type VARCHAR(50) NOT NULL, -- contact_shared, prospect_converted, email_received, etc.
    priority VARCHAR(20) DEFAULT 'medium', -- low, medium, high, urgent
    is_read BOOLEAN DEFAULT false,
    action_url VARCHAR(500),
    metadata JSONB DEFAULT '{}',
    expires_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Table pour le partage de contacts
CREATE TABLE IF NOT EXISTS contact_shares (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    contact_id UUID REFERENCES contacts(id) NOT NULL,
    shared_by UUID REFERENCES collaborators(id) NOT NULL,
    shared_with UUID REFERENCES collaborators(id) NOT NULL,
    permission_level VARCHAR(20) DEFAULT 'view', -- view, edit, full
    message TEXT,
    expires_at TIMESTAMPTZ,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Table pour l'importation de données
CREATE TABLE IF NOT EXISTS data_imports (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    collaborator_id UUID REFERENCES collaborators(id) NOT NULL,
    import_type VARCHAR(50) NOT NULL, -- excel, google_sheets, hubspot, csv
    file_name VARCHAR(255),
    file_path VARCHAR(500),
    source_url VARCHAR(500),
    total_records INTEGER DEFAULT 0,
    processed_records INTEGER DEFAULT 0,
    successful_records INTEGER DEFAULT 0,
    failed_records INTEGER DEFAULT 0,
    status VARCHAR(50) DEFAULT 'pending', -- pending, processing, completed, failed
    error_log TEXT,
    mapping_config JSONB DEFAULT '{}',
    preview_data JSONB DEFAULT '[]',
    created_at TIMESTAMPTZ DEFAULT NOW(),
    completed_at TIMESTAMPTZ
);

-- Table pour les scores d'engagement IA
CREATE TABLE IF NOT EXISTS ai_engagement_scores (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    contact_id UUID REFERENCES contacts(id) NOT NULL,
    score INTEGER CHECK (score >= 0 AND score <= 100),
    factors JSONB DEFAULT '{}', -- Facteurs qui influencent le score
    last_interaction_date TIMESTAMPTZ,
    prediction_confidence DECIMAL(5,4), -- 0.0000 à 1.0000
    recommended_actions JSONB DEFAULT '[]',
    calculated_at TIMESTAMPTZ DEFAULT NOW(),
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Table pour les suggestions IA
CREATE TABLE IF NOT EXISTS ai_suggestions (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    contact_id UUID REFERENCES contacts(id) NOT NULL,
    collaborator_id UUID REFERENCES collaborators(id),
    suggestion_type VARCHAR(50) NOT NULL, -- action, cross_sell, follow_up, etc.
    title VARCHAR(255) NOT NULL,
    description TEXT,
    confidence_score DECIMAL(5,4), -- 0.0000 à 1.0000
    priority VARCHAR(20) DEFAULT 'medium',
    status VARCHAR(50) DEFAULT 'pending', -- pending, accepted, rejected, completed
    metadata JSONB DEFAULT '{}',
    expires_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Table pour les templates d'email
CREATE TABLE IF NOT EXISTS email_templates (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    collaborator_id UUID REFERENCES collaborators(id),
    name VARCHAR(255) NOT NULL,
    subject VARCHAR(500),
    body TEXT NOT NULL,
    template_type VARCHAR(50), -- welcome, follow_up, proposal, etc.
    variables JSONB DEFAULT '[]', -- Variables disponibles dans le template
    is_shared BOOLEAN DEFAULT false,
    usage_count INTEGER DEFAULT 0,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Table pour les intégrations externes
CREATE TABLE IF NOT EXISTS external_integrations (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    collaborator_id UUID REFERENCES collaborators(id),
    integration_type VARCHAR(50) NOT NULL, -- hubspot, google_sheets, mailchimp, etc.
    api_key_encrypted TEXT,
    refresh_token_encrypted TEXT,
    access_token_encrypted TEXT,
    config JSONB DEFAULT '{}',
    last_sync TIMESTAMPTZ,
    sync_frequency INTEGER DEFAULT 3600, -- en secondes
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Indexes pour les performances
CREATE INDEX IF NOT EXISTS idx_emails_contact_id ON emails(contact_id);
CREATE INDEX IF NOT EXISTS idx_emails_collaborator_id ON emails(collaborator_id);
CREATE INDEX IF NOT EXISTS idx_emails_sent_at ON emails(sent_at);
CREATE INDEX IF NOT EXISTS idx_notifications_collaborator_id ON notifications(collaborator_id);
CREATE INDEX IF NOT EXISTS idx_notifications_is_read ON notifications(is_read);
CREATE INDEX IF NOT EXISTS idx_contact_shares_contact_id ON contact_shares(contact_id);
CREATE INDEX IF NOT EXISTS idx_contact_shares_shared_with ON contact_shares(shared_with);
CREATE INDEX IF NOT EXISTS idx_ai_engagement_scores_contact_id ON ai_engagement_scores(contact_id);
CREATE INDEX IF NOT EXISTS idx_ai_suggestions_contact_id ON ai_suggestions(contact_id);
CREATE INDEX IF NOT EXISTS idx_ai_suggestions_status ON ai_suggestions(status);

-- Triggers pour les notifications automatiques
CREATE OR REPLACE FUNCTION create_notification_on_share()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO notifications (collaborator_id, title, message, type, action_url)
    VALUES (
        NEW.shared_with,
        'Contact partagé avec vous',
        'Un contact a été partagé avec vous par ' || (SELECT first_name || ' ' || last_name FROM collaborators WHERE id = NEW.shared_by),
        'contact_shared',
        '/contacts/' || NEW.contact_id
    );
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_notification_on_share
    AFTER INSERT ON contact_shares
    FOR EACH ROW
    EXECUTE FUNCTION create_notification_on_share();

-- Trigger pour mettre à jour le score d'engagement
CREATE OR REPLACE FUNCTION update_engagement_score()
RETURNS TRIGGER AS $$
BEGIN
    -- Logique simplifiée - dans la vraie vie, cela ferait appel à l'IA
    INSERT INTO ai_engagement_scores (contact_id, score, last_interaction_date)
    VALUES (NEW.contact_id, 75, NEW.created_at)
    ON CONFLICT (contact_id) DO UPDATE SET
        score = 75,
        last_interaction_date = NEW.created_at,
        calculated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_update_engagement_score
    AFTER INSERT ON interactions
    FOR EACH ROW
    EXECUTE FUNCTION update_engagement_score();
