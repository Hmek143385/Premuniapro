-- =====================================================
-- SCRIPT COMPLET POUR SUPABASE CRM PRO ASSURANCES
-- =====================================================

-- Activer les extensions nécessaires
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- =====================================================
-- 1. SUPPRESSION DES TABLES EXISTANTES (si elles existent)
-- =====================================================

DROP TABLE IF EXISTS email_workflows CASCADE;
DROP TABLE IF EXISTS email_templates CASCADE;
DROP TABLE IF EXISTS notifications CASCADE;
DROP TABLE IF EXISTS interactions CASCADE;
DROP TABLE IF EXISTS contracts CASCADE;
DROP TABLE IF EXISTS sales_targets CASCADE;
DROP TABLE IF EXISTS contacts CASCADE;
DROP TABLE IF EXISTS products CASCADE;
DROP TABLE IF EXISTS collaborators CASCADE;
DROP TABLE IF EXISTS emails CASCADE;

-- =====================================================
-- 2. CRÉATION DES TABLES
-- =====================================================

-- Table des collaborateurs
CREATE TABLE collaborators (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(255) NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    role VARCHAR(100) NOT NULL,
    phone VARCHAR(20),
    department VARCHAR(100),
    hire_date DATE DEFAULT CURRENT_DATE,
    is_active BOOLEAN DEFAULT true,
    password_hash TEXT DEFAULT crypt('123456789', gen_salt('bf')),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Table des produits
CREATE TABLE products (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(255) NOT NULL,
    category VARCHAR(100) NOT NULL,
    price DECIMAL(10,2) NOT NULL,
    description TEXT,
    commission_rate DECIMAL(5,2) DEFAULT 0,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Table des contacts
CREATE TABLE contacts (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    first_name VARCHAR(255) NOT NULL,
    last_name VARCHAR(255) NOT NULL,
    email VARCHAR(255),
    phone VARCHAR(20),
    address TEXT,
    city VARCHAR(100),
    postal_code VARCHAR(10),
    birth_date DATE,
    profession VARCHAR(100),
    income_range VARCHAR(50),
    family_situation VARCHAR(50),
    source VARCHAR(100),
    status VARCHAR(50) DEFAULT 'prospect',
    assigned_to UUID REFERENCES collaborators(id),
    notes TEXT,
    engagement_score INTEGER DEFAULT 0,
    last_contact_date TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Table des objectifs de vente
CREATE TABLE sales_targets (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    collaborator_id UUID REFERENCES collaborators(id) ON DELETE CASCADE,
    target_type VARCHAR(50) NOT NULL,
    target_value DECIMAL(12,2) NOT NULL,
    current_value DECIMAL(12,2) DEFAULT 0,
    period_start DATE NOT NULL,
    period_end DATE NOT NULL,
    status VARCHAR(20) DEFAULT 'active',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Table des contrats
CREATE TABLE contracts (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    contact_id UUID REFERENCES contacts(id) ON DELETE CASCADE,
    product_id UUID REFERENCES products(id),
    collaborator_id UUID REFERENCES collaborators(id),
    contract_number VARCHAR(100) UNIQUE NOT NULL,
    status VARCHAR(50) DEFAULT 'draft',
    premium_amount DECIMAL(10,2) NOT NULL,
    commission_amount DECIMAL(10,2),
    start_date DATE,
    end_date DATE,
    payment_frequency VARCHAR(20),
    notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Table des interactions
CREATE TABLE interactions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    contact_id UUID REFERENCES contacts(id) ON DELETE CASCADE,
    collaborator_id UUID REFERENCES collaborators(id),
    type VARCHAR(50) NOT NULL,
    subject VARCHAR(255),
    description TEXT,
    outcome VARCHAR(100),
    next_action VARCHAR(255),
    next_action_date TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Table des emails
CREATE TABLE emails (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    contact_id UUID REFERENCES contacts(id) ON DELETE CASCADE,
    collaborator_id UUID REFERENCES collaborators(id),
    subject VARCHAR(255) NOT NULL,
    content TEXT NOT NULL,
    status VARCHAR(20) DEFAULT 'draft',
    sent_at TIMESTAMP WITH TIME ZONE,
    opened_at TIMESTAMP WITH TIME ZONE,
    clicked_at TIMESTAMP WITH TIME ZONE,
    template_id UUID,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Table des templates d'email
CREATE TABLE email_templates (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(255) NOT NULL,
    subject VARCHAR(255) NOT NULL,
    content TEXT NOT NULL,
    category VARCHAR(100),
    target_audience VARCHAR(100),
    is_active BOOLEAN DEFAULT true,
    usage_count INTEGER DEFAULT 0,
    created_by UUID REFERENCES collaborators(id),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Table des workflows d'email
CREATE TABLE email_workflows (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(255) NOT NULL,
    description TEXT,
    trigger_condition JSONB,
    steps JSONB,
    is_active BOOLEAN DEFAULT true,
    created_by UUID REFERENCES collaborators(id),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Table des notifications
CREATE TABLE notifications (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES collaborators(id) ON DELETE CASCADE,
    title VARCHAR(255) NOT NULL,
    message TEXT NOT NULL,
    type VARCHAR(50) DEFAULT 'info',
    is_read BOOLEAN DEFAULT false,
    action_url VARCHAR(500),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- =====================================================
-- 3. INSERTION DES DONNÉES DE TEST
-- =====================================================

-- Insertion des collaborateurs
INSERT INTO collaborators (id, name, email, role, phone, department) VALUES
(uuid_generate_v4(), 'Jean Dupont', 'jean.dupont@crmPro.com', 'Directeur', '01.23.45.67.89', 'Direction'),
(uuid_generate_v4(), 'Marie Martin', 'marie.martin@crmPro.com', 'Commercial Senior', '01.23.45.67.90', 'Commercial'),
(uuid_generate_v4(), 'Pierre Durand', 'pierre.durand@crmPro.com', 'Commercial', '01.23.45.67.91', 'Commercial'),
(uuid_generate_v4(), 'Sophie Leroy', 'sophie.leroy@crmPro.com', 'Service Qualité', '01.23.45.67.92', 'Qualité'),
(uuid_generate_v4(), 'Thomas Moreau', 'thomas.moreau@crmPro.com', 'Gestionnaire', '01.23.45.67.93', 'Gestion');

-- Insertion des produits d'assurance
INSERT INTO products (id, name, category, price, description, commission_rate) VALUES
(uuid_generate_v4(), 'Assurance Vie Sérénité', 'Assurance Vie', 2500.00, 'Contrat d''assurance vie avec garantie décès et épargne progressive', 8.5),
(uuid_generate_v4(), 'Mutuelle Santé Premium', 'Santé', 1200.00, 'Couverture santé complète avec remboursements majorés', 12.0),
(uuid_generate_v4(), 'Assurance Auto Tous Risques', 'Automobile', 800.00, 'Protection complète pour votre véhicule', 15.0),
(uuid_generate_v4(), 'Assurance Habitation Confort', 'Habitation', 450.00, 'Protection optimale de votre domicile et biens', 10.0),
(uuid_generate_v4(), 'Prévoyance Famille', 'Prévoyance', 180.00, 'Protection financière en cas d''arrêt de travail', 20.0);

-- Insertion des contacts (prospects seniors Facebook + autres)
INSERT INTO contacts (id, first_name, last_name, email, phone, address, city, postal_code, birth_date, profession, income_range, family_situation, source, status, notes, engagement_score) VALUES
-- Prospects seniors Facebook (non joignables par téléphone)
(uuid_generate_v4(), 'Françoise', 'Dubois', 'francoise.dubois@gmail.com', NULL, '15 rue des Lilas', 'Lyon', '69000', '1955-03-15', 'Retraitée', '2000-3000€', 'Veuve', 'Facebook', 'prospect', 'Prospect senior Facebook - Non joignable par téléphone. Intéressée par assurance vie.', 75),
(uuid_generate_v4(), 'Robert', 'Lemoine', 'robert.lemoine@orange.fr', NULL, '8 avenue Victor Hugo', 'Marseille', '13000', '1952-08-22', 'Retraité', '3000-4000€', 'Marié', 'Facebook', 'prospect', 'Prospect senior Facebook - Téléphone non communiqué. Recherche mutuelle santé.', 68),
(uuid_generate_v4(), 'Monique', 'Petit', 'monique.petit@wanadoo.fr', NULL, '22 boulevard Saint-Michel', 'Toulouse', '31000', '1958-11-08', 'Retraitée', '1500-2500€', 'Célibataire', 'Facebook', 'prospect', 'Prospect senior Facebook - Pas de téléphone renseigné. Intérêt pour prévoyance.', 82),
(uuid_generate_v4(), 'André', 'Rousseau', 'andre.rousseau@free.fr', NULL, '5 place de la République', 'Nice', '06000', '1950-06-12', 'Retraité', '2500-3500€', 'Veuf', 'Facebook', 'prospect', 'Prospect senior Facebook - Contact uniquement par email. Recherche assurance habitation.', 71),
(uuid_generate_v4(), 'Jacqueline', 'Moreau', 'jacqueline.moreau@gmail.com', NULL, '18 rue de la Paix', 'Strasbourg', '67000', '1956-01-25', 'Retraitée', '2000-3000€', 'Mariée', 'Facebook', 'prospect', 'Prospect senior Facebook - Téléphone non disponible. Intéressée par assurance vie.', 79),

-- Autres prospects et clients
(uuid_generate_v4(), 'Paul', 'Bernard', 'paul.bernard@email.com', '06.12.34.56.78', '12 rue de la Liberté', 'Paris', '75001', '1985-05-10', 'Ingénieur', '4000-5000€', 'Marié', 'Site Web', 'client', 'Client fidèle depuis 3 ans', 95),
(uuid_generate_v4(), 'Julie', 'Garnier', 'julie.garnier@email.com', '06.23.45.67.89', '7 avenue des Champs', 'Bordeaux', '33000', '1990-12-03', 'Médecin', '6000-8000€', 'Célibataire', 'Recommandation', 'prospect', 'Prospect qualifié, rendez-vous prévu', 88),
(uuid_generate_v4(), 'Michel', 'Roux', 'michel.roux@email.com', '06.34.56.78.90', '25 rue du Commerce', 'Lille', '59000', '1978-09-18', 'Commerçant', '3000-4000€', 'Marié', 'Prospection', 'prospect', 'Premier contact établi', 65),
(uuid_generate_v4(), 'Catherine', 'Blanc', 'catherine.blanc@email.com', '06.45.67.89.01', '9 place du Marché', 'Nantes', '44000', '1982-07-22', 'Enseignante', '2500-3500€', 'Mariée', 'Salon', 'client', 'Nouvelle cliente - Contrat signé', 92),
(uuid_generate_v4(), 'Alain', 'Faure', 'alain.faure@email.com', '06.56.78.90.12', '14 rue des Roses', 'Montpellier', '34000', '1975-04-14', 'Artisan', '3500-4500€', 'Marié', 'Recommandation', 'prospect', 'Intéressé par assurance professionnelle', 73),
(uuid_generate_v4(), 'Sylvie', 'Girard', 'sylvie.girard@email.com', '06.67.89.01.23', '3 avenue de la Gare', 'Rennes', '35000', '1988-11-30', 'Cadre', '4500-5500€', 'Célibataire', 'LinkedIn', 'prospect', 'Contact LinkedIn - Profil intéressant', 80),
(uuid_generate_v4(), 'François', 'Lefevre', 'francois.lefevre@email.com', '06.78.90.12.34', '11 boulevard des Arts', 'Dijon', '21000', '1983-02-17', 'Architecte', '5000-6000€', 'Marié', 'Site Web', 'client', 'Client premium - Plusieurs contrats', 98);

-- Insertion des templates d'email pour seniors Facebook
INSERT INTO email_templates (id, name, subject, content, category, target_audience, created_by) VALUES
(uuid_generate_v4(), 'Premier Contact Senior Facebook', 'Votre demande d''information sur nos assurances', 
'Bonjour {{prenom}},

Suite à votre intérêt manifesté sur Facebook pour nos solutions d''assurance, je me permets de vous contacter.

En tant que spécialiste des assurances pour les seniors, je comprends vos préoccupations concernant :
• La protection de votre patrimoine
• La sécurité financière de vos proches
• Les garanties adaptées à votre situation

Je serais ravi de vous présenter nos solutions personnalisées, sans engagement de votre part.

Pourriez-vous me confirmer le meilleur moment pour vous joindre par email ou souhaitez-vous que je vous appelle ?

Cordialement,
{{nom_commercial}}
{{telephone}}
{{email}}', 'Premier contact', 'Seniors Facebook', (SELECT id FROM collaborators WHERE email = 'marie.martin@crmPro.com')),

(uuid_generate_v4(), 'Relance Senior Facebook J+7', 'Nos solutions d''assurance vie adaptées aux seniors', 
'Bonjour {{prenom}},

J''espère que vous allez bien. Je reviens vers vous concernant votre intérêt pour nos solutions d''assurance.

Permettez-moi de vous présenter notre assurance vie "Sérénité Senior" :
✓ Garantie décès immédiate
✓ Capital transmis sans fiscalité
✓ Possibilité de rachat partiel
✓ Gestion simplifiée

Cette solution a été spécialement conçue pour les personnes de votre génération qui souhaitent :
- Protéger leurs proches
- Optimiser la transmission de leur patrimoine
- Garder la maîtrise de leur épargne

Souhaitez-vous que je vous envoie une documentation personnalisée ?

Bien à vous,
{{nom_commercial}}', 'Relance', 'Seniors Facebook', (SELECT id FROM collaborators WHERE email = 'marie.martin@crmPro.com')),

(uuid_generate_v4(), 'Relance Senior Facebook J+15', 'Une question importante sur votre protection santé', 
'Bonjour {{prenom}},

En tant que senior, vous savez combien il est important d''avoir une bonne couverture santé.

Saviez-vous que :
• Les remboursements de la Sécurité Sociale diminuent chaque année
• Les frais de santé augmentent avec l''âge
• Une bonne mutuelle peut vous faire économiser des milliers d''euros

Notre mutuelle "Santé Premium Senior" offre :
- Remboursement à 200% des frais dentaires
- Prise en charge intégrale des lunettes
- Forfait hospitalisation de 100€/jour
- Médecines douces incluses

Je peux vous faire parvenir un devis personnalisé gratuitement.

Cordialement,
{{nom_commercial}}', 'Relance', 'Seniors Facebook', (SELECT id FROM collaborators WHERE email = 'pierre.durand@crmPro.com')),

(uuid_generate_v4(), 'Offre Spéciale Senior Facebook', 'Offre exclusive : -20% sur votre première année', 
'Bonjour {{prenom}},

Bonne nouvelle ! En tant que prospect privilégié via Facebook, vous bénéficiez d''une offre exclusive :

🎁 -20% sur votre première année d''assurance
🎁 Frais de dossier offerts
🎁 Conseil personnalisé gratuit

Cette offre est valable jusqu''au {{date_limite}} et concerne :
• Assurance vie Sérénité
• Mutuelle Santé Premium
• Assurance Habitation Confort

Pour en profiter, il vous suffit de me répondre en précisant :
1. Le type d''assurance qui vous intéresse
2. Vos coordonnées téléphoniques (optionnel)
3. Le meilleur moment pour vous contacter

Ne laissez pas passer cette opportunité !

Très cordialement,
{{nom_commercial}}', 'Offre commerciale', 'Seniors Facebook', (SELECT id FROM collaborators WHERE email = 'marie.martin@crmPro.com')),

(uuid_generate_v4(), 'Dernière Relance Senior Facebook', 'Dernière chance de bénéficier de nos conseils gratuits', 
'Bonjour {{prenom}},

Je n''ai pas eu de retour à mes précédents messages concernant vos besoins en assurance.

Je respecte totalement votre choix si vous n''êtes plus intéressé(e).

Cependant, si c''est simplement par manque de temps ou si vous avez des questions, sachez que :
• Mes conseils sont entièrement gratuits
• Aucun engagement n''est requis
• Je peux m''adapter à vos disponibilités

Si vous souhaitez que je cesse de vous contacter, répondez simplement "STOP" à ce message.

Dans le cas contraire, je reste à votre disposition pour tout renseignement.

Excellente journée,
{{nom_commercial}}
{{telephone}}', 'Dernière relance', 'Seniors Facebook', (SELECT id FROM collaborators WHERE email = 'marie.martin@crmPro.com'));

-- Insertion des workflows d'email
INSERT INTO email_workflows (id, name, description, trigger_condition, steps, created_by) VALUES
(uuid_generate_v4(), 'Workflow Senior Facebook', 'Séquence automatique pour prospects seniors Facebook non joignables', 
'{"source": "Facebook", "age_min": 60, "phone": null}',
'[
  {"day": 0, "template": "Premier Contact Senior Facebook", "action": "send_email"},
  {"day": 7, "template": "Relance Senior Facebook J+7", "action": "send_email"},
  {"day": 15, "template": "Relance Senior Facebook J+15", "action": "send_email"},
  {"day": 30, "template": "Offre Spéciale Senior Facebook", "action": "send_email"},
  {"day": 45, "template": "Dernière Relance Senior Facebook", "action": "send_email"}
]',
(SELECT id FROM collaborators WHERE email = 'marie.martin@crmPro.com')),

(uuid_generate_v4(), 'Workflow Nouveau Client', 'Séquence de bienvenue pour nouveaux clients', 
'{"status": "client", "contract_signed": true}',
'[
  {"day": 0, "action": "send_welcome_email"},
  {"day": 7, "action": "send_satisfaction_survey"},
  {"day": 30, "action": "schedule_follow_up"}
]',
(SELECT id FROM collaborators WHERE email = 'jean.dupont@crmPro.com')),

(uuid_generate_v4(), 'Workflow Prospect Inactif', 'Réactivation des prospects inactifs', 
'{"last_contact": "30_days_ago", "status": "prospect"}',
'[
  {"day": 0, "action": "send_reactivation_email"},
  {"day": 14, "action": "send_special_offer"},
  {"day": 28, "action": "schedule_call"}
]',
(SELECT id FROM collaborators WHERE email = 'pierre.durand@crmPro.com'));

-- Insertion des objectifs de vente
INSERT INTO sales_targets (collaborator_id, target_type, target_value, current_value, period_start, period_end) VALUES
((SELECT id FROM collaborators WHERE email = 'marie.martin@crmPro.com'), 'Chiffre d''affaires', 150000.00, 45000.00, '2024-01-01', '2024-12-31'),
((SELECT id FROM collaborators WHERE email = 'pierre.durand@crmPro.com'), 'Chiffre d''affaires', 120000.00, 38000.00, '2024-01-01', '2024-12-31'),
((SELECT id FROM collaborators WHERE email = 'marie.martin@crmPro.com'), 'Nouveaux clients', 50.00, 18.00, '2024-01-01', '2024-12-31'),
((SELECT id FROM collaborators WHERE email = 'pierre.durand@crmPro.com'), 'Nouveaux clients', 40.00, 15.00, '2024-01-01', '2024-12-31');

-- Insertion de quelques contrats
INSERT INTO contracts (contact_id, product_id, collaborator_id, contract_number, status, premium_amount, commission_amount, start_date, payment_frequency) VALUES
((SELECT id FROM contacts WHERE email = 'paul.bernard@email.com'), (SELECT id FROM products WHERE name = 'Assurance Vie Sérénité'), (SELECT id FROM collaborators WHERE email = 'marie.martin@crmPro.com'), 'AV-2024-001', 'active', 2500.00, 212.50, '2024-01-15', 'Annuel'),
((SELECT id FROM contacts WHERE email = 'catherine.blanc@email.com'), (SELECT id FROM products WHERE name = 'Mutuelle Santé Premium'), (SELECT id FROM collaborators WHERE email = 'pierre.durand@crmPro.com'), 'MS-2024-002', 'active', 1200.00, 144.00, '2024-02-01', 'Mensuel'),
((SELECT id FROM contacts WHERE email = 'francois.lefevre@email.com'), (SELECT id FROM products WHERE name = 'Assurance Auto Tous Risques'), (SELECT id FROM collaborators WHERE email = 'marie.martin@crmPro.com'), 'AA-2024-003', 'active', 800.00, 120.00, '2024-01-20', 'Annuel');

-- Insertion d'interactions
INSERT INTO interactions (contact_id, collaborator_id, type, subject, description, outcome, next_action, next_action_date) VALUES
((SELECT id FROM contacts WHERE first_name = 'Françoise' AND last_name = 'Dubois'), (SELECT id FROM collaborators WHERE email = 'marie.martin@crmPro.com'), 'Email', 'Premier contact Facebook', 'Envoi du premier email de contact suite à son intérêt sur Facebook', 'Email envoyé', 'Attendre réponse puis relancer', NOW() + INTERVAL '7 days'),
((SELECT id FROM contacts WHERE first_name = 'Robert' AND last_name = 'Lemoine'), (SELECT id FROM collaborators WHERE email = 'marie.martin@crmPro.com'), 'Email', 'Information mutuelle santé', 'Envoi d''informations sur la mutuelle santé senior', 'Email ouvert', 'Envoyer devis personnalisé', NOW() + INTERVAL '3 days'),
((SELECT id FROM contacts WHERE email = 'paul.bernard@email.com'), (SELECT id FROM collaborators WHERE email = 'marie.martin@crmPro.com'), 'Téléphone', 'Suivi contrat assurance vie', 'Appel de suivi satisfaction client', 'Très satisfait', 'Proposer produits complémentaires', NOW() + INTERVAL '30 days');

-- Insertion d'emails envoyés
INSERT INTO emails (contact_id, collaborator_id, subject, content, status, sent_at) VALUES
((SELECT id FROM contacts WHERE first_name = 'Françoise' AND last_name = 'Dubois'), (SELECT id FROM collaborators WHERE email = 'marie.martin@crmPro.com'), 'Votre demande d''information sur nos assurances', 'Email personnalisé pour Françoise...', 'sent', NOW() - INTERVAL '2 days'),
((SELECT id FROM contacts WHERE first_name = 'Robert' AND last_name = 'Lemoine'), (SELECT id FROM collaborators WHERE email = 'marie.martin@crmPro.com'), 'Nos solutions d''assurance vie adaptées aux seniors', 'Email de relance pour Robert...', 'sent', NOW() - INTERVAL '1 day'),
((SELECT id FROM contacts WHERE first_name = 'Monique' AND last_name = 'Petit'), (SELECT id FROM collaborators WHERE email = 'pierre.durand@crmPro.com'), 'Une question importante sur votre protection santé', 'Email santé pour Monique...', 'sent', NOW() - INTERVAL '3 hours');

-- Insertion de notifications
INSERT INTO notifications (user_id, title, message, type) VALUES
((SELECT id FROM collaborators WHERE email = 'marie.martin@crmPro.com'), 'Nouveau prospect Facebook', 'Un nouveau prospect senior s''est manifesté via Facebook', 'info'),
((SELECT id FROM collaborators WHERE email = 'pierre.durand@crmPro.com'), 'Objectif mensuel', 'Vous avez atteint 75% de votre objectif mensuel', 'success'),
((SELECT id FROM collaborators WHERE email = 'jean.dupont@crmPro.com'), 'Rapport hebdomadaire', 'Le rapport hebdomadaire est disponible', 'info'),
((SELECT id FROM collaborators WHERE email = 'marie.martin@crmPro.com'), 'Relance à effectuer', 'Relance à effectuer pour Françoise Dubois', 'warning');

-- =====================================================
-- 4. CRÉATION DES INDEX POUR LES PERFORMANCES
-- =====================================================

CREATE INDEX idx_contacts_email ON contacts(email);
CREATE INDEX idx_contacts_status ON contacts(status);
CREATE INDEX idx_contacts_assigned_to ON contacts(assigned_to);
CREATE INDEX idx_contacts_source ON contacts(source);
CREATE INDEX idx_contracts_contact_id ON contracts(contact_id);
CREATE INDEX idx_contracts_status ON contracts(status);
CREATE INDEX idx_interactions_contact_id ON interactions(contact_id);
CREATE INDEX idx_emails_contact_id ON emails(contact_id);
CREATE INDEX idx_emails_status ON emails(status);
CREATE INDEX idx_notifications_user_id ON notifications(user_id);
CREATE INDEX idx_notifications_is_read ON notifications(is_read);

-- =====================================================
-- 5. CRÉATION DES FONCTIONS UTILES
-- =====================================================

-- Fonction pour calculer l'âge
CREATE OR REPLACE FUNCTION calculate_age(birth_date DATE)
RETURNS INTEGER AS $$
BEGIN
    RETURN EXTRACT(YEAR FROM AGE(birth_date));
END;
$$ LANGUAGE plpgsql;

-- Fonction pour mettre à jour le score d'engagement
CREATE OR REPLACE FUNCTION update_engagement_score()
RETURNS TRIGGER AS $$
BEGIN
    UPDATE contacts 
    SET engagement_score = LEAST(100, engagement_score + 10),
        updated_at = NOW()
    WHERE id = NEW.contact_id;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger pour mettre à jour le score d'engagement lors d'une interaction
CREATE TRIGGER trigger_update_engagement_score
    AFTER INSERT ON interactions
    FOR EACH ROW
    EXECUTE FUNCTION update_engagement_score();

-- =====================================================
-- 6. CONFIGURATION DES POLITIQUES RLS (Row Level Security)
-- =====================================================

-- Activer RLS sur les tables sensibles
ALTER TABLE collaborators ENABLE ROW LEVEL SECURITY;
ALTER TABLE contacts ENABLE ROW LEVEL SECURITY;
ALTER TABLE contracts ENABLE ROW LEVEL SECURITY;
ALTER TABLE interactions ENABLE ROW LEVEL SECURITY;
ALTER TABLE emails ENABLE ROW LEVEL SECURITY;
ALTER TABLE notifications ENABLE ROW LEVEL SECURITY;

-- Politique pour les collaborateurs (peuvent voir tous les contacts)
CREATE POLICY "Collaborators can view all contacts" ON contacts
    FOR ALL USING (true);

CREATE POLICY "Collaborators can view all contracts" ON contracts
    FOR ALL USING (true);

CREATE POLICY "Collaborators can view all interactions" ON interactions
    FOR ALL USING (true);

CREATE POLICY "Collaborators can view all emails" ON emails
    FOR ALL USING (true);

-- Politique pour les notifications (chaque utilisateur voit ses notifications)
CREATE POLICY "Users can view own notifications" ON notifications
    FOR ALL USING (auth.uid()::text = user_id::text);

-- =====================================================
-- 7. VUES UTILES POUR LES RAPPORTS
-- =====================================================

-- Vue des contacts avec informations enrichies
CREATE OR REPLACE VIEW v_contacts_enriched AS
SELECT 
    c.*,
    co.name as collaborator_name,
    calculate_age(c.birth_date) as age,
    COUNT(i.id) as interactions_count,
    MAX(i.created_at) as last_interaction_date,
    COUNT(ct.id) as contracts_count,
    COALESCE(SUM(ct.premium_amount), 0) as total_premium
FROM contacts c
LEFT JOIN collaborators co ON c.assigned_to = co.id
LEFT JOIN interactions i ON c.id = i.contact_id
LEFT JOIN contracts ct ON c.id = ct.contact_id
GROUP BY c.id, co.name;

-- Vue des statistiques par collaborateur
CREATE OR REPLACE VIEW v_collaborator_stats AS
SELECT 
    co.id,
    co.name,
    co.email,
    COUNT(DISTINCT c.id) as total_contacts,
    COUNT(DISTINCT CASE WHEN c.status = 'client' THEN c.id END) as clients_count,
    COUNT(DISTINCT CASE WHEN c.status = 'prospect' THEN c.id END) as prospects_count,
    COUNT(DISTINCT ct.id) as contracts_count,
    COALESCE(SUM(ct.premium_amount), 0) as total_revenue,
    COALESCE(SUM(ct.commission_amount), 0) as total_commission
FROM collaborators co
LEFT JOIN contacts c ON co.id = c.assigned_to
LEFT JOIN contracts ct ON co.id = ct.collaborator_id
GROUP BY co.id, co.name, co.email;

-- =====================================================
-- SCRIPT TERMINÉ AVEC SUCCÈS
-- =====================================================

-- Affichage des statistiques finales
SELECT 'INSTALLATION TERMINÉE' as status;
SELECT COUNT(*) as collaborators_count FROM collaborators;
SELECT COUNT(*) as contacts_count FROM contacts;
SELECT COUNT(*) as products_count FROM products;
SELECT COUNT(*) as email_templates_count FROM email_templates;
SELECT COUNT(*) as workflows_count FROM email_workflows;
SELECT COUNT(*) as contracts_count FROM contracts;
SELECT COUNT(*) as interactions_count FROM interactions;
