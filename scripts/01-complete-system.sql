-- Suppression et recréation complète de la base de données
DROP SCHEMA IF EXISTS public CASCADE;
CREATE SCHEMA public;

-- Extension pour UUID
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Table des rôles utilisateurs
CREATE TABLE user_roles (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(50) UNIQUE NOT NULL,
    description TEXT,
    permissions JSONB DEFAULT '{}',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Table des collaborateurs avec rôles
CREATE TABLE collaborators (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    phone VARCHAR(20),
    password_hash VARCHAR(255) NOT NULL,
    role_id UUID REFERENCES user_roles(id),
    is_active BOOLEAN DEFAULT true,
    hire_date DATE,
    commission_rate DECIMAL(5,2) DEFAULT 0.00,
    manager_id UUID REFERENCES collaborators(id),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Table des contacts avec segmentation avancée
CREATE TABLE contacts (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    client_code VARCHAR(20) UNIQUE NOT NULL,
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    email VARCHAR(255),
    phone VARCHAR(20),
    birth_date DATE,
    gender VARCHAR(10),
    address TEXT,
    postal_code VARCHAR(10),
    city VARCHAR(100),
    country VARCHAR(100) DEFAULT 'France',
    source VARCHAR(50),
    status VARCHAR(50) DEFAULT 'prospect',
    regime VARCHAR(50),
    commercial_id VARCHAR(50),
    assigned_to UUID REFERENCES collaborators(id),
    ai_engagement_score INTEGER DEFAULT 0,
    last_interaction_date TIMESTAMP WITH TIME ZONE,
    conversion_probability DECIMAL(5,2) DEFAULT 0.00,
    lifetime_value DECIMAL(10,2) DEFAULT 0.00,
    notes TEXT,
    tags TEXT[],
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Table de partage de contacts
CREATE TABLE contact_shares (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    contact_id UUID REFERENCES contacts(id) ON DELETE CASCADE,
    shared_by UUID REFERENCES collaborators(id),
    shared_with UUID REFERENCES collaborators(id),
    permission_level VARCHAR(20) DEFAULT 'read', -- read, write, full
    message TEXT,
    expires_at TIMESTAMP WITH TIME ZONE,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Table des comptes email
CREATE TABLE email_accounts (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    collaborator_id UUID REFERENCES collaborators(id),
    email_address VARCHAR(255) NOT NULL,
    provider VARCHAR(50), -- gmail, outlook, etc.
    smtp_host VARCHAR(255),
    smtp_port INTEGER,
    smtp_username VARCHAR(255),
    smtp_password_encrypted TEXT,
    imap_host VARCHAR(255),
    imap_port INTEGER,
    is_active BOOLEAN DEFAULT true,
    last_sync TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Table des emails
CREATE TABLE emails (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    contact_id UUID REFERENCES contacts(id),
    collaborator_id UUID REFERENCES collaborators(id),
    email_account_id UUID REFERENCES email_accounts(id),
    from_email VARCHAR(255) NOT NULL,
    to_email VARCHAR(255) NOT NULL,
    cc_emails TEXT[],
    bcc_emails TEXT[],
    subject VARCHAR(500),
    body TEXT,
    html_body TEXT,
    email_type VARCHAR(20) DEFAULT 'outbound', -- inbound, outbound
    status VARCHAR(20) DEFAULT 'draft', -- draft, sent, delivered, opened, clicked, bounced
    thread_id VARCHAR(255),
    message_id VARCHAR(255),
    in_reply_to VARCHAR(255),
    attachments JSONB DEFAULT '[]',
    tracking_data JSONB DEFAULT '{}',
    sent_at TIMESTAMP WITH TIME ZONE,
    delivered_at TIMESTAMP WITH TIME ZONE,
    opened_at TIMESTAMP WITH TIME ZONE,
    clicked_at TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Table des templates d'email
CREATE TABLE email_templates (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(255) NOT NULL,
    category VARCHAR(100),
    subject VARCHAR(500),
    body TEXT,
    html_body TEXT,
    variables JSONB DEFAULT '[]',
    usage_count INTEGER DEFAULT 0,
    is_active BOOLEAN DEFAULT true,
    created_by UUID REFERENCES collaborators(id),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Table des workflows
CREATE TABLE workflows (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(255) NOT NULL,
    description TEXT,
    trigger_type VARCHAR(50) NOT NULL, -- contact_created, status_changed, email_opened, etc.
    trigger_conditions JSONB DEFAULT '{}',
    actions JSONB DEFAULT '[]',
    is_active BOOLEAN DEFAULT true,
    execution_count INTEGER DEFAULT 0,
    success_count INTEGER DEFAULT 0,
    failure_count INTEGER DEFAULT 0,
    created_by UUID REFERENCES collaborators(id),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Table d'exécution des workflows
CREATE TABLE workflow_executions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    workflow_id UUID REFERENCES workflows(id),
    contact_id UUID REFERENCES contacts(id),
    trigger_data JSONB DEFAULT '{}',
    status VARCHAR(20) DEFAULT 'pending', -- pending, running, completed, failed
    started_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    completed_at TIMESTAMP WITH TIME ZONE,
    error_message TEXT,
    execution_log JSONB DEFAULT '[]'
);

-- Table des objectifs de vente
CREATE TABLE sales_targets (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    collaborator_id UUID REFERENCES collaborators(id),
    target_type VARCHAR(50) NOT NULL, -- revenue, contracts, leads
    target_value DECIMAL(12,2) NOT NULL,
    min_value DECIMAL(12,2) NOT NULL,
    current_value DECIMAL(12,2) DEFAULT 0.00,
    period_type VARCHAR(20) DEFAULT 'monthly', -- daily, weekly, monthly, quarterly, yearly
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    weight DECIMAL(5,2) DEFAULT 100.00,
    bonus_rate DECIMAL(5,2) DEFAULT 0.00,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Table des KPI personnalisés
CREATE TABLE custom_kpis (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(255) NOT NULL,
    description TEXT,
    formula TEXT NOT NULL, -- SQL formula or calculation logic
    target_value DECIMAL(12,2),
    current_value DECIMAL(12,2),
    unit VARCHAR(50),
    frequency VARCHAR(20) DEFAULT 'daily', -- daily, weekly, monthly
    collaborator_id UUID REFERENCES collaborators(id),
    is_active BOOLEAN DEFAULT true,
    last_calculated TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Table des rapports
CREATE TABLE reports (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(255) NOT NULL,
    description TEXT,
    report_type VARCHAR(50) NOT NULL, -- sales, performance, conversion, cross_selling
    parameters JSONB DEFAULT '{}',
    schedule JSONB DEFAULT '{}', -- cron-like schedule
    recipients UUID[] DEFAULT '{}',
    last_generated TIMESTAMP WITH TIME ZONE,
    is_active BOOLEAN DEFAULT true,
    created_by UUID REFERENCES collaborators(id),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Table des données de rapport
CREATE TABLE report_data (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    report_id UUID REFERENCES reports(id),
    data JSONB NOT NULL,
    period_start DATE,
    period_end DATE,
    generated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Table des produits d'assurance
CREATE TABLE insurance_products (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(255) NOT NULL,
    category VARCHAR(100),
    description TEXT,
    base_premium DECIMAL(10,2),
    commission_rate DECIMAL(5,2),
    min_age INTEGER,
    max_age INTEGER,
    coverage_amount DECIMAL(12,2),
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Table des contrats
CREATE TABLE contracts (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    contract_number VARCHAR(50) UNIQUE NOT NULL,
    contact_id UUID REFERENCES contacts(id),
    product_id UUID REFERENCES insurance_products(id),
    collaborator_id UUID REFERENCES collaborators(id),
    status VARCHAR(50) DEFAULT 'draft',
    premium_amount DECIMAL(10,2),
    commission_amount DECIMAL(10,2),
    start_date DATE,
    end_date DATE,
    payment_frequency VARCHAR(20) DEFAULT 'monthly',
    signed_date DATE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Table des interactions
CREATE TABLE interactions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    contact_id UUID REFERENCES contacts(id),
    collaborator_id UUID REFERENCES collaborators(id),
    type VARCHAR(50) NOT NULL,
    subject VARCHAR(255),
    description TEXT,
    outcome VARCHAR(100),
    next_action VARCHAR(255),
    next_action_date DATE,
    duration_minutes INTEGER,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Table des notifications
CREATE TABLE notifications (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    collaborator_id UUID REFERENCES collaborators(id),
    title VARCHAR(255) NOT NULL,
    message TEXT,
    type VARCHAR(50) DEFAULT 'info',
    priority VARCHAR(20) DEFAULT 'medium',
    is_read BOOLEAN DEFAULT false,
    action_url VARCHAR(500),
    expires_at TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Table des imports de données
CREATE TABLE data_imports (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    collaborator_id UUID REFERENCES collaborators(id),
    import_type VARCHAR(50) NOT NULL,
    file_name VARCHAR(255),
    file_size INTEGER,
    status VARCHAR(20) DEFAULT 'pending',
    total_records INTEGER DEFAULT 0,
    successful_records INTEGER DEFAULT 0,
    failed_records INTEGER DEFAULT 0,
    error_log TEXT,
    started_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    completed_at TIMESTAMP WITH TIME ZONE
);

-- Table des intégrations externes
CREATE TABLE external_integrations (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(100) NOT NULL,
    type VARCHAR(50) NOT NULL, -- hubspot, google_sheets, calendly
    config JSONB DEFAULT '{}',
    credentials_encrypted TEXT,
    is_active BOOLEAN DEFAULT true,
    last_sync TIMESTAMP WITH TIME ZONE,
    sync_frequency INTEGER DEFAULT 3600, -- seconds
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Table des suggestions IA
CREATE TABLE ai_suggestions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    contact_id UUID REFERENCES contacts(id),
    collaborator_id UUID REFERENCES collaborators(id),
    suggestion_type VARCHAR(50) NOT NULL,
    title VARCHAR(255),
    description TEXT,
    confidence_score DECIMAL(5,2),
    action_data JSONB DEFAULT '{}',
    status VARCHAR(20) DEFAULT 'pending',
    applied_at TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Index pour les performances
CREATE INDEX idx_contacts_assigned_to ON contacts(assigned_to);
CREATE INDEX idx_contacts_status ON contacts(status);
CREATE INDEX idx_contacts_source ON contacts(source);
CREATE INDEX idx_contacts_postal_code ON contacts(postal_code);
CREATE INDEX idx_contacts_city ON contacts(city);
CREATE INDEX idx_contacts_commercial_id ON contacts(commercial_id);
CREATE INDEX idx_emails_contact_id ON emails(contact_id);
CREATE INDEX idx_emails_collaborator_id ON emails(collaborator_id);
CREATE INDEX idx_emails_status ON emails(status);
CREATE INDEX idx_interactions_contact_id ON interactions(contact_id);
CREATE INDEX idx_notifications_collaborator_id ON notifications(collaborator_id);
CREATE INDEX idx_notifications_is_read ON notifications(is_read);
CREATE INDEX idx_contracts_contact_id ON contracts(contact_id);
CREATE INDEX idx_contracts_collaborator_id ON contracts(collaborator_id);
CREATE INDEX idx_workflow_executions_status ON workflow_executions(status);
CREATE INDEX idx_contact_shares_shared_with ON contact_shares(shared_with);

-- Triggers pour les mises à jour automatiques
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

CREATE TRIGGER update_contacts_updated_at BEFORE UPDATE ON contacts
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_collaborators_updated_at BEFORE UPDATE ON collaborators
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_contracts_updated_at BEFORE UPDATE ON contracts
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Fonction pour calculer le score d'engagement IA
CREATE OR REPLACE FUNCTION calculate_engagement_score(contact_uuid UUID)
RETURNS INTEGER AS $$
DECLARE
    score INTEGER := 0;
    interaction_count INTEGER;
    email_count INTEGER;
    last_interaction_days INTEGER;
BEGIN
    -- Compter les interactions
    SELECT COUNT(*) INTO interaction_count
    FROM interactions
    WHERE contact_id = contact_uuid
    AND created_at > NOW() - INTERVAL '30 days';
    
    -- Compter les emails
    SELECT COUNT(*) INTO email_count
    FROM emails
    WHERE contact_id = contact_uuid
    AND created_at > NOW() - INTERVAL '30 days';
    
    -- Calculer les jours depuis la dernière interaction
    SELECT COALESCE(EXTRACT(DAY FROM NOW() - MAX(created_at)), 999) INTO last_interaction_days
    FROM interactions
    WHERE contact_id = contact_uuid;
    
    -- Calcul du score
    score := score + (interaction_count * 10);
    score := score + (email_count * 5);
    
    IF last_interaction_days <= 7 THEN
        score := score + 20;
    ELSIF last_interaction_days <= 30 THEN
        score := score + 10;
    END IF;
    
    -- Limiter le score entre 0 et 100
    score := GREATEST(0, LEAST(100, score));
    
    RETURN score;
END;
$$ LANGUAGE plpgsql;

-- Trigger pour mettre à jour le score d'engagement
CREATE OR REPLACE FUNCTION update_engagement_score()
RETURNS TRIGGER AS $$
BEGIN
    UPDATE contacts
    SET ai_engagement_score = calculate_engagement_score(NEW.contact_id),
        updated_at = NOW()
    WHERE id = NEW.contact_id;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_update_engagement_score_interactions
    AFTER INSERT OR UPDATE ON interactions
    FOR EACH ROW EXECUTE FUNCTION update_engagement_score();

CREATE TRIGGER trigger_update_engagement_score_emails
    AFTER INSERT OR UPDATE ON emails
    FOR EACH ROW EXECUTE FUNCTION update_engagement_score();

-- Fonction pour créer des notifications automatiques
CREATE OR REPLACE FUNCTION create_notification(
    p_collaborator_id UUID,
    p_title VARCHAR(255),
    p_message TEXT,
    p_type VARCHAR(50) DEFAULT 'info',
    p_priority VARCHAR(20) DEFAULT 'medium'
)
RETURNS UUID AS $$
DECLARE
    notification_id UUID;
BEGIN
    INSERT INTO notifications (collaborator_id, title, message, type, priority)
    VALUES (p_collaborator_id, p_title, p_message, p_type, p_priority)
    RETURNING id INTO notification_id;
    
    RETURN notification_id;
END;
$$ LANGUAGE plpgsql;

-- Trigger pour notifications de partage
CREATE OR REPLACE FUNCTION notify_contact_share()
RETURNS TRIGGER AS $$
DECLARE
    contact_name VARCHAR(255);
    sharer_name VARCHAR(255);
BEGIN
    SELECT CONCAT(first_name, ' ', last_name) INTO contact_name
    FROM contacts WHERE id = NEW.contact_id;
    
    SELECT CONCAT(first_name, ' ', last_name) INTO sharer_name
    FROM collaborators WHERE id = NEW.shared_by;
    
    PERFORM create_notification(
        NEW.shared_with,
        'Contact partagé',
        sharer_name || ' a partagé le contact ' || contact_name || ' avec vous.',
        'contact_shared',
        'medium'
    );
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_notify_contact_share
    AFTER INSERT ON contact_shares
    FOR EACH ROW EXECUTE FUNCTION notify_contact_share();

-- Fonction pour exécuter les workflows
CREATE OR REPLACE FUNCTION execute_workflow(workflow_uuid UUID, contact_uuid UUID, trigger_data JSONB DEFAULT '{}')
RETURNS UUID AS $$
DECLARE
    execution_id UUID;
    workflow_actions JSONB;
    action JSONB;
BEGIN
    -- Créer l'exécution
    INSERT INTO workflow_executions (workflow_id, contact_id, trigger_data, status)
    VALUES (workflow_uuid, contact_uuid, trigger_data, 'running')
    RETURNING id INTO execution_id;
    
    -- Récupérer les actions du workflow
    SELECT actions INTO workflow_actions
    FROM workflows
    WHERE id = workflow_uuid AND is_active = true;
    
    -- Exécuter chaque action (simulation)
    FOR action IN SELECT * FROM jsonb_array_elements(workflow_actions)
    LOOP
        -- Ici vous implémenteriez la logique d'exécution des actions
        -- Par exemple: envoyer un email, créer une tâche, etc.
        NULL;
    END LOOP;
    
    -- Marquer comme terminé
    UPDATE workflow_executions
    SET status = 'completed', completed_at = NOW()
    WHERE id = execution_id;
    
    -- Incrémenter le compteur de succès
    UPDATE workflows
    SET success_count = success_count + 1
    WHERE id = workflow_uuid;
    
    RETURN execution_id;
END;
$$ LANGUAGE plpgsql;

-- Fonction pour générer des rapports automatiques
CREATE OR REPLACE FUNCTION generate_sales_report(
    p_collaborator_id UUID DEFAULT NULL,
    p_start_date DATE DEFAULT NULL,
    p_end_date DATE DEFAULT NULL
)
RETURNS JSONB AS $$
DECLARE
    report_data JSONB;
    total_contracts INTEGER;
    total_revenue DECIMAL(12,2);
    conversion_rate DECIMAL(5,2);
    avg_deal_size DECIMAL(10,2);
BEGIN
    -- Définir les dates par défaut
    p_start_date := COALESCE(p_start_date, DATE_TRUNC('month', CURRENT_DATE));
    p_end_date := COALESCE(p_end_date, CURRENT_DATE);
    
    -- Calculer les métriques
    SELECT 
        COUNT(*),
        COALESCE(SUM(premium_amount), 0),
        COALESCE(AVG(premium_amount), 0)
    INTO total_contracts, total_revenue, avg_deal_size
    FROM contracts c
    WHERE (p_collaborator_id IS NULL OR c.collaborator_id = p_collaborator_id)
    AND c.signed_date BETWEEN p_start_date AND p_end_date
    AND c.status = 'active';
    
    -- Calculer le taux de conversion
    WITH prospects AS (
        SELECT COUNT(*) as prospect_count
        FROM contacts
        WHERE (p_collaborator_id IS NULL OR assigned_to = p_collaborator_id)
        AND created_at::date BETWEEN p_start_date AND p_end_date
        AND status = 'prospect'
    )
    SELECT 
        CASE 
            WHEN prospect_count > 0 THEN (total_contracts::DECIMAL / prospect_count * 100)
            ELSE 0
        END
    INTO conversion_rate
    FROM prospects;
    
    -- Construire le JSON de rapport
    report_data := jsonb_build_object(
        'period', jsonb_build_object(
            'start_date', p_start_date,
            'end_date', p_end_date
        ),
        'metrics', jsonb_build_object(
            'total_contracts', total_contracts,
            'total_revenue', total_revenue,
            'conversion_rate', conversion_rate,
            'avg_deal_size', avg_deal_size
        ),
        'generated_at', NOW()
    );
    
    RETURN report_data;
END;
$$ LANGUAGE plpgsql;
