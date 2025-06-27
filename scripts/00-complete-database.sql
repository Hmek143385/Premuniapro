-- Suppression et recréation complète de la base de données
DROP SCHEMA IF EXISTS public CASCADE;
CREATE SCHEMA public;

-- Extension pour UUID
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Table des collaborateurs
CREATE TABLE collaborators (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    email VARCHAR(255) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    role VARCHAR(50) NOT NULL DEFAULT 'commercial',
    commission_rate NUMERIC(5,4) DEFAULT 0.0000,
    hire_date DATE DEFAULT CURRENT_DATE,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Table des contacts
CREATE TABLE contacts (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    client_code VARCHAR(50) UNIQUE NOT NULL,
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    birth_date DATE,
    email VARCHAR(255),
    phone VARCHAR(20),
    postal_code VARCHAR(10),
    city VARCHAR(100),
    family_situation VARCHAR(50),
    profession VARCHAR(100),
    source VARCHAR(50),
    status VARCHAR(50) DEFAULT 'prospect',
    health_profile JSONB DEFAULT '{}',
    assigned_to UUID REFERENCES collaborators(id),
    engagement_score INTEGER DEFAULT 50,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Table des produits d'assurance
CREATE TABLE insurance_products (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    code VARCHAR(50) UNIQUE NOT NULL,
    name VARCHAR(200) NOT NULL,
    category VARCHAR(100) NOT NULL,
    base_price NUMERIC(10,2) NOT NULL,
    commission_rate NUMERIC(5,4) DEFAULT 0.0000,
    cross_sell_priority INTEGER DEFAULT 0,
    recommended_products UUID[] DEFAULT '{}',
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Table des contrats
CREATE TABLE contracts (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    contract_number VARCHAR(100) UNIQUE NOT NULL,
    contact_id UUID REFERENCES contacts(id) NOT NULL,
    product_id UUID REFERENCES insurance_products(id) NOT NULL,
    full_name VARCHAR(200) NOT NULL,
    city VARCHAR(100),
    signature_date DATE NOT NULL,
    start_date DATE NOT NULL,
    end_date DATE,
    monthly_premium NUMERIC(10,2) NOT NULL,
    annual_premium NUMERIC(10,2) NOT NULL,
    monthly_commission NUMERIC(10,2) DEFAULT 0,
    annual_commission NUMERIC(10,2) DEFAULT 0,
    first_year_commission NUMERIC(10,2) DEFAULT 0,
    recurring_commission NUMERIC(10,2) DEFAULT 0,
    received_commission NUMERIC(10,2) DEFAULT 0,
    status VARCHAR(50) DEFAULT 'active',
    assigned_to UUID REFERENCES collaborators(id),
    country VARCHAR(100) DEFAULT 'France',
    charge NUMERIC(10,2) DEFAULT 0,
    expenses NUMERIC(10,2) DEFAULT 0,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Table des interactions
CREATE TABLE interactions (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    contact_id UUID REFERENCES contacts(id) NOT NULL,
    type VARCHAR(50) NOT NULL,
    outcome VARCHAR(100),
    scheduled_at TIMESTAMPTZ,
    completed_at TIMESTAMPTZ,
    duration_minutes INTEGER DEFAULT 0,
    notes TEXT,
    next_step VARCHAR(200),
    collaborator_id UUID REFERENCES collaborators(id) NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Table des objectifs de vente
CREATE TABLE sales_targets (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    collaborator_id UUID REFERENCES collaborators(id) NOT NULL,
    target_type VARCHAR(50) NOT NULL,
    target_value NUMERIC(12,2) NOT NULL,
    min_value NUMERIC(12,2) DEFAULT 0,
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    weight INTEGER DEFAULT 100,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Table des comptes email
CREATE TABLE email_accounts (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    collaborator_id UUID REFERENCES collaborators(id) NOT NULL,
    email VARCHAR(255) NOT NULL,
    provider VARCHAR(50) NOT NULL,
    imap_host VARCHAR(255),
    imap_port INTEGER DEFAULT 993,
    smtp_host VARCHAR(255),
    smtp_port INTEGER DEFAULT 587,
    username VARCHAR(255) NOT NULL,
    password_encrypted TEXT,
    is_active BOOLEAN DEFAULT true,
    last_sync TIMESTAMPTZ,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Table des emails
CREATE TABLE emails (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    email_account_id UUID REFERENCES email_accounts(id),
    contact_id UUID REFERENCES contacts(id),
    collaborator_id UUID REFERENCES collaborators(id) NOT NULL,
    subject VARCHAR(500),
    body TEXT,
    from_email VARCHAR(255) NOT NULL,
    to_email VARCHAR(255) NOT NULL,
    cc_email TEXT,
    bcc_email TEXT,
    email_type VARCHAR(50) DEFAULT 'outbound',
    status VARCHAR(50) DEFAULT 'sent',
    message_id VARCHAR(255),
    thread_id VARCHAR(255),
    attachments JSONB DEFAULT '[]',
    metadata JSONB DEFAULT '{}',
    sent_at TIMESTAMPTZ,
    opened_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Table des notifications
CREATE TABLE notifications (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    collaborator_id UUID REFERENCES collaborators(id) NOT NULL,
    title VARCHAR(255) NOT NULL,
    message TEXT NOT NULL,
    type VARCHAR(50) NOT NULL,
    priority VARCHAR(20) DEFAULT 'medium',
    is_read BOOLEAN DEFAULT false,
    action_url VARCHAR(500),
    metadata JSONB DEFAULT '{}',
    expires_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Table de partage de contacts
CREATE TABLE contact_shares (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    contact_id UUID REFERENCES contacts(id) NOT NULL,
    shared_by UUID REFERENCES collaborators(id) NOT NULL,
    shared_with UUID REFERENCES collaborators(id) NOT NULL,
    permission_level VARCHAR(20) DEFAULT 'view',
    message TEXT,
    expires_at TIMESTAMPTZ,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Table des imports de données
CREATE TABLE data_imports (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    collaborator_id UUID REFERENCES collaborators(id) NOT NULL,
    import_type VARCHAR(50) NOT NULL,
    file_name VARCHAR(255),
    file_path VARCHAR(500),
    source_url VARCHAR(500),
    total_records INTEGER DEFAULT 0,
    processed_records INTEGER DEFAULT 0,
    successful_records INTEGER DEFAULT 0,
    failed_records INTEGER DEFAULT 0,
    status VARCHAR(50) DEFAULT 'pending',
    error_log TEXT,
    mapping_config JSONB DEFAULT '{}',
    preview_data JSONB DEFAULT '[]',
    created_at TIMESTAMPTZ DEFAULT NOW(),
    completed_at TIMESTAMPTZ,
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Table des scores d'engagement IA
CREATE TABLE ai_engagement_scores (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    contact_id UUID REFERENCES contacts(id) NOT NULL UNIQUE,
    score INTEGER CHECK (score >= 0 AND score <= 100),
    factors JSONB DEFAULT '{}',
    last_interaction_date TIMESTAMPTZ,
    prediction_confidence DECIMAL(5,4),
    recommended_actions JSONB DEFAULT '[]',
    calculated_at TIMESTAMPTZ DEFAULT NOW(),
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Table des suggestions IA
CREATE TABLE ai_suggestions (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    contact_id UUID REFERENCES contacts(id) NOT NULL,
    collaborator_id UUID REFERENCES collaborators(id),
    suggestion_type VARCHAR(50) NOT NULL,
    title VARCHAR(255) NOT NULL,
    description TEXT,
    confidence_score DECIMAL(5,4),
    priority VARCHAR(20) DEFAULT 'medium',
    status VARCHAR(50) DEFAULT 'pending',
    metadata JSONB DEFAULT '{}',
    expires_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Table des templates d'email
CREATE TABLE email_templates (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    collaborator_id UUID REFERENCES collaborators(id),
    name VARCHAR(255) NOT NULL,
    subject VARCHAR(500),
    body TEXT NOT NULL,
    template_type VARCHAR(50),
    variables JSONB DEFAULT '[]',
    is_shared BOOLEAN DEFAULT false,
    usage_count INTEGER DEFAULT 0,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Table des intégrations externes
CREATE TABLE external_integrations (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    collaborator_id UUID REFERENCES collaborators(id),
    integration_type VARCHAR(50) NOT NULL,
    api_key_encrypted TEXT,
    refresh_token_encrypted TEXT,
    access_token_encrypted TEXT,
    config JSONB DEFAULT '{}',
    last_sync TIMESTAMPTZ,
    sync_frequency INTEGER DEFAULT 3600,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Table des workflows
CREATE TABLE workflows (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    name VARCHAR(200) NOT NULL,
    trigger_type VARCHAR(50) NOT NULL,
    trigger_config JSONB DEFAULT '{}',
    actions JSONB DEFAULT '[]',
    is_active BOOLEAN DEFAULT true,
    created_by UUID REFERENCES collaborators(id) NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Table des logs de workflow
CREATE TABLE workflow_logs (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    workflow_id UUID REFERENCES workflows(id) NOT NULL,
    contact_id UUID REFERENCES contacts(id),
    triggered_at TIMESTAMPTZ DEFAULT NOW(),
    status VARCHAR(50) DEFAULT 'pending',
    execution_details TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Indexes pour les performances
CREATE INDEX idx_contacts_assigned_to ON contacts(assigned_to);
CREATE INDEX idx_contacts_status ON contacts(status);
CREATE INDEX idx_contacts_email ON contacts(email);
CREATE INDEX idx_contracts_contact_id ON contracts(contact_id);
CREATE INDEX idx_contracts_assigned_to ON contracts(assigned_to);
CREATE INDEX idx_contracts_status ON contracts(status);
CREATE INDEX idx_interactions_contact_id ON interactions(contact_id);
CREATE INDEX idx_interactions_collaborator_id ON interactions(collaborator_id);
CREATE INDEX idx_interactions_created_at ON interactions(created_at);
CREATE INDEX idx_emails_contact_id ON emails(contact_id);
CREATE INDEX idx_emails_collaborator_id ON emails(collaborator_id);
CREATE INDEX idx_emails_sent_at ON emails(sent_at);
CREATE INDEX idx_notifications_collaborator_id ON notifications(collaborator_id);
CREATE INDEX idx_notifications_is_read ON notifications(is_read);
CREATE INDEX idx_contact_shares_contact_id ON contact_shares(contact_id);
CREATE INDEX idx_contact_shares_shared_with ON contact_shares(shared_with);
CREATE INDEX idx_ai_engagement_scores_contact_id ON ai_engagement_scores(contact_id);
CREATE INDEX idx_ai_suggestions_contact_id ON ai_suggestions(contact_id);
CREATE INDEX idx_ai_suggestions_status ON ai_suggestions(status);
CREATE INDEX idx_sales_targets_collaborator_id ON sales_targets(collaborator_id);

-- Fonctions utilitaires
CREATE OR REPLACE FUNCTION generate_client_code()
RETURNS VARCHAR AS $$
DECLARE
    new_code VARCHAR;
    counter INTEGER := 1;
BEGIN
    LOOP
        new_code := 'CL' || LPAD(counter::TEXT, 6, '0');
        IF NOT EXISTS (SELECT 1 FROM contacts WHERE client_code = new_code) THEN
            RETURN new_code;
        END IF;
        counter := counter + 1;
    END LOOP;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION generate_contract_number()
RETURNS VARCHAR AS $$
DECLARE
    new_number VARCHAR;
    counter INTEGER := 1;
BEGIN
    LOOP
        new_number := 'CT' || TO_CHAR(NOW(), 'YYYY') || LPAD(counter::TEXT, 6, '0');
        IF NOT EXISTS (SELECT 1 FROM contracts WHERE contract_number = new_number) THEN
            RETURN new_number;
        END IF;
        counter := counter + 1;
    END LOOP;
END;
$$ LANGUAGE plpgsql;

-- Trigger pour auto-générer le code client
CREATE OR REPLACE FUNCTION set_client_code()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.client_code IS NULL OR NEW.client_code = '' THEN
        NEW.client_code := generate_client_code();
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_set_client_code
    BEFORE INSERT ON contacts
    FOR EACH ROW
    EXECUTE FUNCTION set_client_code();

-- Trigger pour auto-générer le numéro de contrat
CREATE OR REPLACE FUNCTION set_contract_number()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.contract_number IS NULL OR NEW.contract_number = '' THEN
        NEW.contract_number := generate_contract_number();
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_set_contract_number
    BEFORE INSERT ON contracts
    FOR EACH ROW
    EXECUTE FUNCTION set_contract_number();

-- Fonction pour mettre à jour updated_at
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Triggers pour updated_at
CREATE TRIGGER trigger_collaborators_updated_at
    BEFORE UPDATE ON collaborators
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER trigger_contacts_updated_at
    BEFORE UPDATE ON contacts
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER trigger_insurance_products_updated_at
    BEFORE UPDATE ON insurance_products
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER trigger_contracts_updated_at
    BEFORE UPDATE ON contracts
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER trigger_interactions_updated_at
    BEFORE UPDATE ON interactions
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- Trigger pour créer une notification lors du partage
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
DECLARE
    interaction_count INTEGER;
    days_since_last INTEGER;
    new_score INTEGER;
BEGIN
    -- Compter les interactions
    SELECT COUNT(*) INTO interaction_count
    FROM interactions 
    WHERE contact_id = NEW.contact_id;
    
    -- Calculer les jours depuis la dernière interaction
    SELECT EXTRACT(DAY FROM NOW() - MAX(created_at)) INTO days_since_last
    FROM interactions 
    WHERE contact_id = NEW.contact_id;
    
    -- Calculer le nouveau score
    new_score := 50; -- Score de base
    
    IF interaction_count >= 5 THEN
        new_score := new_score + 20;
    ELSIF interaction_count >= 2 THEN
        new_score := new_score + 10;
    END IF;
    
    IF days_since_last IS NOT NULL THEN
        IF days_since_last <= 7 THEN
            new_score := new_score + 20;
        ELSIF days_since_last <= 30 THEN
            new_score := new_score + 10;
        ELSE
            new_score := new_score - 10;
        END IF;
    END IF;
    
    -- Limiter entre 0 et 100
    new_score := GREATEST(0, LEAST(100, new_score));
    
    -- Mettre à jour le score
    INSERT INTO ai_engagement_scores (contact_id, score, last_interaction_date, calculated_at)
    VALUES (NEW.contact_id, new_score, NEW.created_at, NOW())
    ON CONFLICT (contact_id) DO UPDATE SET
        score = new_score,
        last_interaction_date = NEW.created_at,
        calculated_at = NOW();
    
    -- Mettre à jour aussi dans la table contacts
    UPDATE contacts SET engagement_score = new_score WHERE id = NEW.contact_id;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_update_engagement_score
    AFTER INSERT ON interactions
    FOR EACH ROW
    EXECUTE FUNCTION update_engagement_score();
