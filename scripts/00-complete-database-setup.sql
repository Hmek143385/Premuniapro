-- =====================================================
-- SCRIPT COMPLET CRM PRO ASSURANCES - TOUT EN UN
-- =====================================================

-- Activer les extensions nécessaires
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- =====================================================
-- 1. SUPPRESSION ET CRÉATION DES TABLES
-- =====================================================

DROP TABLE IF EXISTS workflow_executions CASCADE;
DROP TABLE IF EXISTS email_workflows CASCADE;
DROP TABLE IF EXISTS email_templates CASCADE;
DROP TABLE IF EXISTS notifications CASCADE;
DROP TABLE IF EXISTS interactions CASCADE;
DROP TABLE IF EXISTS contracts CASCADE;
DROP TABLE IF EXISTS sales_targets CASCADE;
DROP TABLE IF EXISTS contacts CASCADE;
DROP TABLE IF EXISTS insurance_products CASCADE;
DROP TABLE IF EXISTS collaborators CASCADE;
DROP TABLE IF EXISTS emails CASCADE;
DROP TABLE IF EXISTS ai_engagement_scores CASCADE;
DROP TABLE IF EXISTS ai_suggestions CASCADE;
DROP TABLE IF EXISTS reports CASCADE;
DROP TABLE IF EXISTS user_kpis CASCADE;

-- Table des collaborateurs avec KPI personnalisés
CREATE TABLE collaborators (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    first_name VARCHAR(255) NOT NULL,
    last_name VARCHAR(255) NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    role VARCHAR(100) NOT NULL,
    phone VARCHAR(20),
    department VARCHAR(100),
    hire_date DATE DEFAULT CURRENT_DATE,
    is_active BOOLEAN DEFAULT true,
    password_hash TEXT DEFAULT crypt('123456789', gen_salt('bf')),
    avatar_url TEXT,
    monthly_target DECIMAL(10,2) DEFAULT 0,
    annual_target DECIMAL(10,2) DEFAULT 0,
    commission_rate DECIMAL(5,2) DEFAULT 10.0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Table des produits d'assurance
CREATE TABLE insurance_products (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    code VARCHAR(20) UNIQUE NOT NULL,
    name VARCHAR(255) NOT NULL,
    category VARCHAR(100) NOT NULL,
    base_price DECIMAL(10,2) NOT NULL,
    description TEXT,
    commission_rate DECIMAL(5,2) DEFAULT 0,
    min_age INTEGER DEFAULT 18,
    max_age INTEGER DEFAULT 99,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Table des contacts avec scoring IA
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
    ai_score DECIMAL(5,2) DEFAULT 0,
    last_contact_date TIMESTAMP WITH TIME ZONE,
    conversion_probability DECIMAL(5,2) DEFAULT 0,
    estimated_value DECIMAL(10,2) DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Table des objectifs de vente par collaborateur
CREATE TABLE sales_targets (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    collaborator_id UUID REFERENCES collaborators(id) ON DELETE CASCADE,
    target_type VARCHAR(50) NOT NULL,
    target_value DECIMAL(12,2) NOT NULL,
    min_value DECIMAL(12,2) DEFAULT 0,
    current_value DECIMAL(12,2) DEFAULT 0,
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    weight INTEGER DEFAULT 100,
    status VARCHAR(20) DEFAULT 'active',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Table des contrats
CREATE TABLE contracts (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    contact_id UUID REFERENCES contacts(id) ON DELETE CASCADE,
    product_id UUID REFERENCES insurance_products(id),
    collaborator_id UUID REFERENCES collaborators(id),
    full_name VARCHAR(500) NOT NULL,
    city VARCHAR(100),
    contract_number VARCHAR(100) UNIQUE DEFAULT 'CTR-' || EXTRACT(YEAR FROM NOW()) || '-' || LPAD(nextval('contract_seq')::text, 6, '0'),
    status VARCHAR(50) DEFAULT 'draft',
    signature_date DATE,
    start_date DATE,
    end_date DATE,
    monthly_premium DECIMAL(10,2),
    annual_premium DECIMAL(10,2),
    total_premium DECIMAL(10,2),
    commission_rate DECIMAL(5,2),
    received_commission DECIMAL(10,2),
    payment_frequency VARCHAR(20) DEFAULT 'monthly',
    notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Séquence pour les numéros de contrat
CREATE SEQUENCE IF NOT EXISTS contract_seq START 1;

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
    duration_minutes INTEGER,
    completed_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Table des emails avec tracking avancé
CREATE TABLE emails (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    contact_id UUID REFERENCES contacts(id) ON DELETE CASCADE,
    collaborator_id UUID REFERENCES collaborators(id),
    subject VARCHAR(255) NOT NULL,
    body TEXT NOT NULL,
    from_email VARCHAR(255) NOT NULL,
    to_email VARCHAR(255) NOT NULL,
    email_type VARCHAR(50) DEFAULT 'outbound',
    status VARCHAR(20) DEFAULT 'draft',
    template_id UUID,
    sent_at TIMESTAMP WITH TIME ZONE,
    delivered_at TIMESTAMP WITH TIME ZONE,
    opened_at TIMESTAMP WITH TIME ZONE,
    clicked_at TIMESTAMP WITH TIME ZONE,
    bounced_at TIMESTAMP WITH TIME ZONE,
    unsubscribed_at TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Table des templates d'email
CREATE TABLE email_templates (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    collaborator_id UUID REFERENCES collaborators(id),
    name VARCHAR(255) NOT NULL,
    subject VARCHAR(255) NOT NULL,
    body TEXT NOT NULL,
    template_type VARCHAR(100),
    variables JSONB DEFAULT '[]',
    category VARCHAR(100),
    target_audience VARCHAR(100),
    is_active BOOLEAN DEFAULT true,
    usage_count INTEGER DEFAULT 0,
    success_rate DECIMAL(5,2) DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Table des workflows d'automatisation
CREATE TABLE workflows (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(255) NOT NULL,
    description TEXT,
    trigger_type VARCHAR(50) NOT NULL,
    trigger_config JSONB,
    actions JSONB,
    is_active BOOLEAN DEFAULT true,
    execution_count INTEGER DEFAULT 0,
    success_count INTEGER DEFAULT 0,
    created_by UUID REFERENCES collaborators(id),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Table des exécutions de workflows
CREATE TABLE workflow_executions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    workflow_id UUID REFERENCES workflows(id) ON DELETE CASCADE,
    contact_id UUID REFERENCES contacts(id) ON DELETE CASCADE,
    status VARCHAR(50) DEFAULT 'pending',
    started_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    completed_at TIMESTAMP WITH TIME ZONE,
    error_message TEXT,
    execution_data JSONB,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Table des notifications personnalisées
CREATE TABLE notifications (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    collaborator_id UUID REFERENCES collaborators(id) ON DELETE CASCADE,
    title VARCHAR(255) NOT NULL,
    message TEXT NOT NULL,
    type VARCHAR(50) DEFAULT 'info',
    priority VARCHAR(20) DEFAULT 'medium',
    is_read BOOLEAN DEFAULT false,
    action_url VARCHAR(500),
    related_contact_id UUID REFERENCES contacts(id),
    related_contract_id UUID REFERENCES contracts(id),
    expires_at TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Table des scores d'engagement IA
CREATE TABLE ai_engagement_scores (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    contact_id UUID REFERENCES contacts(id) ON DELETE CASCADE,
    score INTEGER NOT NULL CHECK (score >= 0 AND score <= 100),
    factors JSONB,
    last_interaction_date TIMESTAMP WITH TIME ZONE,
    prediction_confidence DECIMAL(3,2),
    recommended_actions JSONB,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Table des suggestions IA
CREATE TABLE ai_suggestions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    contact_id UUID REFERENCES contacts(id) ON DELETE CASCADE,
    suggestion_type VARCHAR(50) NOT NULL,
    title VARCHAR(255) NOT NULL,
    description TEXT,
    confidence_score DECIMAL(3,2),
    priority VARCHAR(20) DEFAULT 'medium',
    status VARCHAR(20) DEFAULT 'pending',
    implemented_at TIMESTAMP WITH TIME ZONE,
    feedback_score INTEGER,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Table des KPI personnalisés par utilisateur
CREATE TABLE user_kpis (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    collaborator_id UUID REFERENCES collaborators(id) ON DELETE CASCADE,
    period_start DATE NOT NULL,
    period_end DATE NOT NULL,
    total_contacts INTEGER DEFAULT 0,
    new_prospects INTEGER DEFAULT 0,
    converted_clients INTEGER DEFAULT 0,
    total_revenue DECIMAL(12,2) DEFAULT 0,
    total_commission DECIMAL(12,2) DEFAULT 0,
    contracts_signed INTEGER DEFAULT 0,
    calls_made INTEGER DEFAULT 0,
    emails_sent INTEGER DEFAULT 0,
    meetings_held INTEGER DEFAULT 0,
    conversion_rate DECIMAL(5,2) DEFAULT 0,
    avg_deal_size DECIMAL(10,2) DEFAULT 0,
    target_achievement DECIMAL(5,2) DEFAULT 0,
    ranking INTEGER DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(collaborator_id, period_start, period_end)
);

-- Table des rapports personnalisés
CREATE TABLE reports (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    collaborator_id UUID REFERENCES collaborators(id) ON DELETE CASCADE,
    report_type VARCHAR(50) NOT NULL,
    title VARCHAR(255) NOT NULL,
    filters JSONB,
    data JSONB,
    period_start DATE,
    period_end DATE,
    is_scheduled BOOLEAN DEFAULT false,
    schedule_frequency VARCHAR(20),
    last_generated TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- =====================================================
-- 2. INSERTION DES DONNÉES COMPLÈTES
-- =====================================================

-- Insertion des collaborateurs avec objectifs personnalisés
INSERT INTO collaborators (id, first_name, last_name, email, role, phone, department, monthly_target, annual_target, commission_rate) VALUES
('00000000-0000-0000-0000-000000000001', 'Jean', 'Dupont', 'jean.dupont@crmPro.com', 'Directeur', '01.23.45.67.89', 'Direction', 0, 0, 5.0),
('00000000-0000-0000-0000-000000000002', 'Marie', 'Martin', 'marie.martin@crmPro.com', 'Commercial Senior', '01.23.45.67.90', 'Commercial', 12500, 150000, 12.0),
('00000000-0000-0000-0000-000000000003', 'Pierre', 'Durand', 'pierre.durand@crmPro.com', 'Commercial', '01.23.45.67.91', 'Commercial', 10000, 120000, 10.0),
('00000000-0000-0000-0000-000000000004', 'Sophie', 'Leroy', 'sophie.leroy@crmPro.com', 'Service Qualité', '01.23.45.67.92', 'Qualité', 0, 0, 0),
('00000000-0000-0000-0000-000000000005', 'Thomas', 'Moreau', 'thomas.moreau@crmPro.com', 'Gestionnaire', '01.23.45.67.93', 'Gestion', 0, 0, 0);

-- Insertion des produits d'assurance complets
INSERT INTO insurance_products (id, code, name, category, base_price, description, commission_rate, min_age, max_age) VALUES
('10000000-0000-0000-0000-000000000001', 'VIE001', 'Assurance Vie Sérénité Senior', 'Assurance Vie', 2500.00, 'Contrat d''assurance vie spécialement conçu pour les seniors avec garantie décès immédiate et épargne progressive', 8.5, 50, 85),
('10000000-0000-0000-0000-000000000002', 'SANTE001', 'Mutuelle Santé Premium Senior', 'Santé', 1200.00, 'Couverture santé complète pour seniors avec remboursements majorés dentaire, optique et hospitalisation', 12.0, 55, 99),
('10000000-0000-0000-0000-000000000003', 'AUTO001', 'Assurance Auto Tous Risques', 'Automobile', 800.00, 'Protection complète pour votre véhicule avec assistance 24h/24', 15.0, 18, 99),
('10000000-0000-0000-0000-000000000004', 'HAB001', 'Assurance Habitation Confort', 'Habitation', 450.00, 'Protection optimale de votre domicile et biens personnels', 10.0, 18, 99),
('10000000-0000-0000-0000-000000000005', 'PREV001', 'Prévoyance Famille Plus', 'Prévoyance', 180.00, 'Protection financière complète en cas d''arrêt de travail ou invalidité', 20.0, 18, 65);

-- Insertion des contacts avec profils détaillés
INSERT INTO contacts (id, first_name, last_name, email, phone, address, city, postal_code, birth_date, profession, income_range, family_situation, source, status, assigned_to, notes, engagement_score, ai_score, conversion_probability, estimated_value) VALUES
-- Prospects seniors Facebook (non joignables par téléphone)
('20000000-0000-0000-0000-000000000001', 'Françoise', 'Dubois', 'francoise.dubois@gmail.com', NULL, '15 rue des Lilas', 'Lyon', '69000', '1955-03-15', 'Retraitée', '2000-3000€', 'Veuve', 'Facebook', 'prospect', '00000000-0000-0000-0000-000000000002', 'Prospect senior Facebook - Non joignable par téléphone. Très intéressée par assurance vie. A perdu son mari récemment.', 75, 8.2, 0.78, 2500.00),
('20000000-0000-0000-0000-000000000002', 'Robert', 'Lemoine', 'robert.lemoine@orange.fr', NULL, '8 avenue Victor Hugo', 'Marseille', '13000', '1952-08-22', 'Retraité', '3000-4000€', 'Marié', 'Facebook', 'prospect', '00000000-0000-0000-0000-000000000002', 'Prospect senior Facebook - Téléphone non communiqué. Recherche mutuelle santé pour lui et sa femme.', 68, 7.5, 0.65, 2400.00),
('20000000-0000-0000-0000-000000000003', 'Monique', 'Petit', 'monique.petit@wanadoo.fr', NULL, '22 boulevard Saint-Michel', 'Toulouse', '31000', '1958-11-08', 'Retraitée', '1500-2500€', 'Célibataire', 'Facebook', 'prospect', '00000000-0000-0000-0000-000000000003', 'Prospect senior Facebook - Pas de téléphone renseigné. Intérêt pour prévoyance et assurance habitation.', 82, 8.8, 0.85, 1800.00),
('20000000-0000-0000-0000-000000000004', 'André', 'Rousseau', 'andre.rousseau@free.fr', NULL, '5 place de la République', 'Nice', '06000', '1950-06-12', 'Retraité', '2500-3500€', 'Veuf', 'Facebook', 'prospect', '00000000-0000-0000-0000-000000000002', 'Prospect senior Facebook - Contact uniquement par email. Propriétaire, recherche assurance habitation haut de gamme.', 71, 7.8, 0.72, 2200.00),
('20000000-0000-0000-0000-000000000005', 'Jacqueline', 'Moreau', 'jacqueline.moreau@gmail.com', NULL, '18 rue de la Paix', 'Strasbourg', '67000', '1956-01-25', 'Retraitée', '2000-3000€', 'Mariée', 'Facebook', 'prospect', '00000000-0000-0000-0000-000000000002', 'Prospect senior Facebook - Téléphone non disponible. Couple de retraités intéressés par assurance vie.', 79, 8.5, 0.81, 3000.00),

-- Autres prospects et clients
('20000000-0000-0000-0000-000000000006', 'Paul', 'Bernard', 'paul.bernard@email.com', '06.12.34.56.78', '12 rue de la Liberté', 'Paris', '75001', '1985-05-10', 'Ingénieur', '4000-5000€', 'Marié', 'Site Web', 'client', '00000000-0000-0000-0000-000000000002', 'Client fidèle depuis 3 ans. Très satisfait de nos services.', 95, 9.5, 0.95, 5000.00),
('20000000-0000-0000-0000-000000000007', 'Julie', 'Garnier', 'julie.garnier@email.com', '06.23.45.67.89', '7 avenue des Champs', 'Bordeaux', '33000', '1990-12-03', 'Médecin', '6000-8000€', 'Célibataire', 'Recommandation', 'prospect', '00000000-0000-0000-0000-000000000002', 'Prospect qualifié, rendez-vous prévu la semaine prochaine.', 88, 9.2, 0.88, 4500.00),
('20000000-0000-0000-0000-000000000008', 'Michel', 'Roux', 'michel.roux@email.com', '06.34.56.78.90', '25 rue du Commerce', 'Lille', '59000', '1978-09-18', 'Commerçant', '3000-4000€', 'Marié', 'Prospection', 'prospect', '00000000-0000-0000-0000-000000000003', 'Premier contact établi. Intéressé par assurance professionnelle.', 65, 6.8, 0.62, 2800.00),
('20000000-0000-0000-0000-000000000009', 'Catherine', 'Blanc', 'catherine.blanc@email.com', '06.45.67.89.01', '9 place du Marché', 'Nantes', '44000', '1982-07-22', 'Enseignante', '2500-3500€', 'Mariée', 'Salon', 'client', '00000000-0000-0000-0000-000000000002', 'Nouvelle cliente - Contrat signé le mois dernier.', 92, 9.0, 0.92, 3200.00),
('20000000-0000-0000-0000-000000000010', 'Alain', 'Faure', 'alain.faure@email.com', '06.56.78.90.12', '14 rue des Roses', 'Montpellier', '34000', '1975-04-14', 'Artisan', '3500-4500€', 'Marié', 'Recommandation', 'prospect', '00000000-0000-0000-0000-000000000003', 'Intéressé par assurance professionnelle et prévoyance.', 73, 7.2, 0.70, 3800.00);

-- Templates d'email spécialisés pour seniors Facebook
INSERT INTO email_templates (id, collaborator_id, name, subject, body, template_type, variables, category, target_audience) VALUES
('30000000-0000-0000-0000-000000000001', '00000000-0000-0000-0000-000000000002', 'Premier Contact Senior Facebook', 'Suite à votre demande d''information sur nos assurances', 
'Bonjour {{first_name}},

Suite à votre intérêt manifesté sur Facebook pour nos solutions d''assurance, j''espère que vous allez bien.

En tant que spécialiste des assurances pour les seniors, je comprends parfaitement vos préoccupations concernant :
• La protection de votre patrimoine familial
• La sécurité financière de vos proches
• Les garanties adaptées à votre situation de retraité(e)

Nos solutions sont spécialement conçues pour les personnes de votre génération, avec des avantages exclusifs :
✓ Tarifs préférentiels seniors
✓ Garanties simplifiées sans questionnaire médical complexe
✓ Conseil personnalisé à domicile si souhaité
✓ Gestion administrative simplifiée

Je serais ravi de vous présenter nos solutions personnalisées, sans aucun engagement de votre part.

Pourriez-vous me confirmer le meilleur moment pour vous contacter par email ? Je peux également vous appeler si vous le souhaitez.

Dans l''attente de votre retour, je vous souhaite une excellente journée.

Cordialement,
{{collaborator_name}}
Conseiller Senior Spécialisé
📞 {{collaborator_phone}}
📧 {{collaborator_email}}

P.S. : N''hésitez pas à me poser toutes vos questions, je suis là pour vous accompagner.', 'fb_senior_contact', '["first_name", "collaborator_name", "collaborator_phone", "collaborator_email"]', 'Premier contact', 'Seniors Facebook'),

('30000000-0000-0000-0000-000000000002', '00000000-0000-0000-0000-000000000002', 'Relance Senior Facebook - Assurance Vie', 'Protégez vos proches avec notre Assurance Vie Sérénité Senior', 
'Bonjour {{first_name}},

J''espère que vous allez bien. Je reviens vers vous concernant votre intérêt pour nos solutions d''assurance.

Permettez-moi de vous présenter notre assurance vie "Sérénité Senior", spécialement conçue pour les personnes de votre âge :

🛡️ **Garanties exclusives seniors :**
• Garantie décès immédiate (pas de délai de carence)
• Capital transmis à vos bénéficiaires sans fiscalité
• Possibilité de rachat partiel en cas de besoin
• Rente viagère optionnelle pour compléter votre retraite

💰 **Avantages financiers :**
• Tarifs préférentiels après 55 ans
• Frais de gestion réduits
• Versements libres à partir de 50€/mois
• Exonération de droits de succession

📋 **Simplicité garantie :**
• Souscription simplifiée (questionnaire médical allégé)
• Gestion 100% digitale ou courrier selon votre préférence
• Conseiller dédié joignable facilement

Cette solution a déjà séduit plus de 15 000 seniors qui ont fait confiance à notre expertise.

Souhaitez-vous que je vous envoie une simulation personnalisée gratuite ?

Il me suffit de connaître :
- Votre âge exact
- Le capital souhaité pour vos proches
- Votre budget mensuel envisagé

Bien à vous,
{{collaborator_name}}
Spécialiste Assurance Vie Senior', 'fb_senior_vie', '["first_name", "collaborator_name"]', 'Relance produit', 'Seniors Facebook'),

('30000000-0000-0000-0000-000000000003', '00000000-0000-0000-0000-000000000003', 'Relance Senior Facebook - Santé', 'Votre santé mérite la meilleure protection', 
'Bonjour {{first_name}},

En tant que senior, vous savez combien il est crucial d''avoir une excellente couverture santé.

**La réalité des chiffres :**
• Les remboursements Sécurité Sociale couvrent seulement 70% des frais
• Les frais dentaires et optiques explosent après 60 ans
• Une hospitalisation peut coûter jusqu''à 100€ par jour
• Les dépassements d''honoraires sont de plus en plus fréquents

**Notre Mutuelle Santé Premium Senior vous offre :**

🦷 **Dentaire exceptionnel :**
• Remboursement jusqu''à 300% des tarifs Sécu
• Implants et prothèses pris en charge
• Pas de délai de carence

👓 **Optique premium :**
• 2 paires de lunettes par an
• Verres progressifs haut de gamme inclus
• Lentilles remboursées

🏥 **Hospitalisation confort :**
• Chambre particulière garantie
• Forfait 150€/jour d''hospitalisation
• Ambulance et transport sanitaire

💊 **Médecines alternatives :**
• Ostéopathie, acupuncture, homéopathie
• Cure thermale prise en charge
• Vaccins et médecine préventive

**Tarif spécial senior : à partir de 89€/mois**

Puis-je vous envoyer un devis personnalisé en fonction de vos besoins spécifiques ?

Cordialement,
{{collaborator_name}}
Expert Santé Senior', 'fb_senior_sante', '["first_name", "collaborator_name"]', 'Relance produit', 'Seniors Facebook'),

('30000000-0000-0000-0000-000000000004', '00000000-0000-0000-0000-000000000002', 'Offre Exclusive Senior Facebook', '🎁 Offre exclusive : -30% sur votre première année', 
'Bonjour {{first_name}},

**EXCELLENTE NOUVELLE !**

En tant que prospect privilégié via Facebook, vous bénéficiez d''une offre exceptionnelle valable uniquement jusqu''au {{date_limite}} :

🎁 **VOTRE CADEAU DE BIENVENUE :**
• -30% sur votre première année d''assurance
• Frais de dossier entièrement offerts (valeur 150€)
• Consultation conseil gratuite à domicile
• Hotline senior dédiée 7j/7

**Cette offre concerne :**
✅ Assurance Vie Sérénité Senior (-30% = 1 750€ au lieu de 2 500€)
✅ Mutuelle Santé Premium Senior (-30% = 840€ au lieu de 1 200€)
✅ Assurance Habitation Confort (-30% = 315€ au lieu de 450€)

**Pourquoi cette offre exclusive ?**
Nous savons que les seniors comme vous méritent une attention particulière. Cette remise exceptionnelle nous permet de vous faire découvrir la qualité de nos services.

**Témoignage client :**
*"Grâce à cette offre, j''ai pu souscrire une excellente assurance vie. Le service client est remarquable et adapté aux seniors. Je recommande vivement !"* - Mme Dubois, 68 ans, Lyon

**Pour en profiter, c''est simple :**
1. Répondez à cet email en précisant le produit qui vous intéresse
2. Je vous envoie immédiatement votre devis personnalisé
3. Vous validez avant le {{date_limite}}

⏰ **ATTENTION : Plus que {{jours_restants}} jours pour en profiter !**

Ne laissez pas passer cette opportunité unique.

Très cordialement,
{{collaborator_name}}
Conseiller Senior Privilégié
📞 {{collaborator_phone}} (ligne directe)', 'fb_senior_offre', '["first_name", "date_limite", "jours_restants", "collaborator_name", "collaborator_phone"]', 'Offre commerciale', 'Seniors Facebook'),

('30000000-0000-0000-0000-000000000005', '00000000-0000-0000-0000-000000000002', 'Dernière Relance Senior Facebook', 'Dernière chance : votre dossier sera archivé demain', 
'Bonjour {{first_name}},

C''est avec regret que je vous informe que votre dossier de demande d''information sera automatiquement archivé demain si je n''ai pas de retour de votre part.

**Je comprends parfaitement que :**
• Vous êtes peut-être occupé(e) ou en déplacement
• Vous avez des doutes ou des questions non résolues
• Vous souhaitez prendre le temps de la réflexion
• Vous préférez peut-être un contact téléphonique

**Permettez-moi de vous rassurer :**
Notre approche est différente des autres assureurs. Nous prenons le temps d''écouter vos besoins réels et nous ne vous proposons que ce qui vous convient vraiment.

**Aucune pression commerciale :** Notre rôle est de vous conseiller, pas de vous vendre à tout prix.

**Si vous souhaitez garder votre dossier ouvert :**
• Répondez simplement "OUI" à cet email
• Ou appelez-moi au {{collaborator_phone}}
• Ou indiquez-moi le meilleur moment pour vous contacter

**Si vous préférez ne plus être contacté(e) :**
Je respecterai totalement votre choix. Répondez "STOP" et vous ne recevrez plus aucun message de ma part.

**Une dernière information importante :**
Les tarifs des assurances augmentent chaque année. En souscrivant maintenant, vous bénéficiez des conditions actuelles qui seront revalorisées l''année prochaine.

Quoi que vous décidiez, je vous remercie pour l''attention que vous avez portée à mes messages.

Je vous souhaite une excellente journée.

Cordialement,
{{collaborator_name}}
Conseiller Senior Spécialisé

P.S. : Si vous connaissez d''autres personnes qui pourraient être intéressées par nos services, n''hésitez pas à leur transmettre mes coordonnées. Je leur réserverai le même accueil personnalisé.', 'fb_senior_derniere', '["first_name", "collaborator_phone", "collaborator_name"]', 'Dernière relance', 'Seniors Facebook');

-- Workflows d'automatisation avancés
INSERT INTO workflows (id, name, description, trigger_type, trigger_config, actions, is_active, created_by) VALUES
('40000000-0000-0000-0000-000000000001', 'Séquence Senior Facebook Automatique', 'Workflow automatique pour prospects seniors Facebook non joignables par téléphone', 'contact_created', 
'{"conditions": [{"field": "source", "operator": "equals", "value": "Facebook"}, {"field": "birth_date", "operator": "before", "value": "1965-01-01"}, {"field": "phone", "operator": "is_null", "value": true}]}',
'[
  {"type": "wait", "duration": "2_hours"},
  {"type": "send_email", "template_id": "30000000-0000-0000-0000-000000000001", "delay": "0"},
  {"type": "create_task", "title": "Suivre réponse email {{first_name}} {{last_name}}", "delay": "1_day"},
  {"type": "wait", "duration": "7_days"},
  {"type": "send_email", "template_id": "30000000-0000-0000-0000-000000000002", "delay": "0"},
  {"type": "wait", "duration": "7_days"},
  {"type": "send_email", "template_id": "30000000-0000-0000-0000-000000000003", "delay": "0"},
  {"type": "wait", "duration": "15_days"},
  {"type": "send_email", "template_id": "30000000-0000-0000-0000-000000000004", "delay": "0"},
  {"type": "create_notification", "title": "Offre exclusive envoyée", "message": "Offre -30% envoyée à {{first_name}} {{last_name}}", "delay": "1_hour"},
  {"type": "wait", "duration": "15_days"},
  {"type": "send_email", "template_id": "30000000-0000-0000-0000-000000000005", "delay": "0"},
  {"type": "create_task", "title": "Décision finale pour {{first_name}} {{last_name}}", "delay": "2_days"}
]', true, '00000000-0000-0000-0000-000000000002'),

('40000000-0000-0000-0000-000000000002', 'Bienvenue Nouveau Client', 'Séquence d''accueil pour nouveaux clients', 'contract_signed',
'{"conditions": [{"field": "status", "operator": "equals", "value": "active"}]}',
'[
  {"type": "send_email", "template": "bienvenue_client", "delay": "1_hour"},
  {"type": "create_notification", "title": "Nouveau client à féliciter", "message": "{{full_name}} a signé un contrat", "delay": "0"},
  {"type": "schedule_call", "title": "Appel satisfaction J+7", "delay": "7_days"},
  {"type": "send_satisfaction_survey", "delay": "30_days"}
]', true, '00000000-0000-0000-0000-000000000001'),

('40000000-0000-0000-0000-000000000003', 'Réactivation Prospects Inactifs', 'Relance automatique des prospects sans interaction depuis 30 jours', 'scheduled',
'{"schedule": "weekly", "day": "monday", "time": "09:00", "conditions": [{"field": "last_contact_date", "operator": "older_than", "value": "30_days"}, {"field": "status", "operator": "equals", "value": "prospect"}]}',
'[
  {"type": "send_email", "template": "reactivation_prospect", "delay": "0"},
  {"type": "create_task", "title": "Relancer prospects inactifs", "delay": "0"},
  {"type": "update_engagement_score", "action": "decrease", "value": 10, "delay": "0"}
]', true, '00000000-0000-0000-0000-000000000001');

-- Objectifs de vente personnalisés par collaborateur
INSERT INTO sales_targets (id, collaborator_id, target_type, target_value, min_value, start_date, end_date, weight) VALUES
('50000000-0000-0000-0000-000000000001', '00000000-0000-0000-0000-000000000002', 'revenue', 150000.00, 120000.00, '2024-01-01', '2024-12-31', 100),
('50000000-0000-0000-0000-000000000002', '00000000-0000-0000-0000-000000000003', 'revenue', 120000.00, 90000.00, '2024-01-01', '2024-12-31', 100),
('50000000-0000-0000-0000-000000000003', '00000000-0000-0000-0000-000000000002', 'contracts', 60, 45, '2024-01-01', '2024-12-31', 80),
('50000000-0000-0000-0000-000000000004', '00000000-0000-0000-0000-000000000003', 'contracts', 48, 36, '2024-01-01', '2024-12-31', 80),
('50000000-0000-0000-0000-000000000005', '00000000-0000-0000-0000-000000000002', 'new_clients', 25, 18, '2024-01-01', '2024-12-31', 60),
('50000000-0000-0000-0000-000000000006', '00000000-0000-0000-0000-000000000003', 'new_clients', 20, 15, '2024-01-01', '2024-12-31', 60);

-- Contrats avec commissions calculées
INSERT INTO contracts (id, contact_id, product_id, collaborator_id, full_name, city, signature_date, start_date, monthly_premium, annual_premium, total_premium, commission_rate, received_commission, status) VALUES
('60000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000006', '10000000-0000-0000-0000-000000000001', '00000000-0000-0000-0000-000000000002', 'Paul Bernard', 'Paris', '2024-01-15', '2024-02-01', 208.33, 2500.00, 2500.00, 8.5, 212.50, 'active'),
('60000000-0000-0000-0000-000000000002', '20000000-0000-0000-0000-000000000009', '10000000-0000-0000-0000-000000000002', '00000000-0000-0000-0000-000000000002', 'Catherine Blanc', 'Nantes', '2024-02-01', '2024-02-15', 100.00, 1200.00, 1200.00, 12.0, 144.00, 'active'),
('60000000-0000-0000-0000-000000000003', '20000000-0000-0000-0000-000000000008', '10000000-0000-0000-0000-000000000003', '00000000-0000-0000-0000-000000000003', 'Michel Roux', 'Lille', '2024-01-20', '2024-02-01', 66.67, 800.00, 800.00, 15.0, 120.00, 'active');

-- Interactions détaillées
INSERT INTO interactions (id, contact_id, collaborator_id, type, subject, description, outcome, duration_minutes, completed_at, notes) VALUES
('70000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000001', '00000000-0000-0000-0000-000000000002', 'email', 'Premier contact Facebook', 'Envoi du premier email de contact suite à son intérêt manifesté sur Facebook pour l''assurance vie', 'Email envoyé - En attente de réponse', 5, NOW() - INTERVAL '2 days', 'Prospect senior très intéressant. Veuve récente, patrimoine à protéger.'),
('70000000-0000-0000-0000-000000000002', '20000000-0000-0000-0000-000000000002', '00000000-0000-0000-0000-000000000002', 'email', 'Information mutuelle santé', 'Envoi d''informations détaillées sur notre mutuelle santé premium senior', 'Email ouvert - Intérêt confirmé', 8, NOW() - INTERVAL '1 day', 'A ouvert l''email 3 fois. Très intéressé par les garanties dentaires.'),
('70000000-0000-0000-0000-000000000003', '20000000-0000-0000-0000-000000000006', '00000000-0000-0000-0000-000000000002', 'call', 'Suivi satisfaction client', 'Appel de suivi pour s''assurer de la satisfaction du client après signature', 'Très satisfait - Recommandation possible', 15, NOW() - INTERVAL '3 days', 'Client très content. Prêt à recommander nos services à ses collègues.'),
('70000000-0000-0000-0000-000000000004', '20000000-0000-0000-0000-000000000007', '00000000-0000-0000-0000-000000000002', 'meeting', 'Rendez-vous commercial', 'Présentation des solutions d''assurance adaptées à sa profession médicale', 'Rendez-vous pris pour signature', 45, NOW() - INTERVAL '5 days', 'Médecin très intéressée. Signature prévue la semaine prochaine.');

-- Emails avec tracking complet
INSERT INTO emails (id, contact_id, collaborator_id, subject, body, from_email, to_email, email_type, status, template_id, sent_at, delivered_at, opened_at) VALUES
('80000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000001', '00000000-0000-0000-0000-000000000002', 'Suite à votre demande d''information sur nos assurances', 'Email personnalisé pour Françoise Dubois...', 'marie.martin@crmPro.com', 'francoise.dubois@gmail.com', 'outbound', 'delivered', '30000000-0000-0000-0000-000000000001', NOW() - INTERVAL '2 days', NOW() - INTERVAL '2 days', NOW() - INTERVAL '1 day'),
('80000000-0000-0000-0000-000000000002', '20000000-0000-0000-0000-000000000002', '00000000-0000-0000-0000-000000000002', 'Votre santé mérite la meilleure protection', 'Email santé personnalisé pour Robert Lemoine...', 'marie.martin@crmPro.com', 'robert.lemoine@orange.fr', 'outbound', 'opened', '30000000-0000-0000-0000-000000000003', NOW() - INTERVAL '1 day', NOW() - INTERVAL '1 day', NOW() - INTERVAL '12 hours');

-- Scores d'engagement IA
INSERT INTO ai_engagement_scores (contact_id, score, factors, last_interaction_date, prediction_confidence, recommended_actions) VALUES
('20000000-0000-0000-0000-000000000001', 78, '{"email_opens": 2, "source": "Facebook", "age_group": "senior", "family_situation": "veuve", "income_level": "medium"}', NOW() - INTERVAL '1 day', 0.82, '["Envoyer devis assurance vie personnalisé", "Proposer rendez-vous téléphonique", "Suivre par email dans 3 jours"]'),
('20000000-0000-0000-0000-000000000002', 71, '{"email_opens": 3, "source": "Facebook", "age_group": "senior", "family_situation": "marié", "income_level": "good"}', NOW() - INTERVAL '12 hours', 0.75, '["Envoyer devis mutuelle couple", "Proposer documentation complémentaire", "Planifier rappel dans 5 jours"]');

-- Suggestions IA personnalisées
INSERT INTO ai_suggestions (contact_id, suggestion_type, title, description, confidence_score, priority) VALUES
('20000000-0000-0000-0000-000000000001', 'cross_sell', 'Opportunité Assurance Habitation', 'Françoise Dubois est propriétaire et pourrait être intéressée par une assurance habitation en complément de l''assurance vie', 0.78, 'high'),
('20000000-0000-0000-0000-000000000002', 'follow_up', 'Relance recommandée', 'Robert Lemoine a ouvert l''email 3 fois mais n''a pas répondu. Une relance personnalisée est recommandée', 0.85, 'medium'),
('20000000-0000-0000-0000-000000000007', 'upsell', 'Proposition Premium', 'Julie Garnier a un profil médecin avec revenus élevés. Proposer les gammes premium', 0.92, 'high');

-- KPI personnalisés par collaborateur
INSERT INTO user_kpis (collaborator_id, period_start, period_end, total_contacts, new_prospects, converted_clients, total_revenue, total_commission, contracts_signed, calls_made, emails_sent, meetings_held, conversion_rate, avg_deal_size, target_achievement) VALUES
('00000000-0000-0000-0000-000000000002', '2024-01-01', '2024-01-31', 15, 8, 3, 4200.00, 356.50, 2, 25, 45, 8, 20.0, 2100.00, 28.0),
('00000000-0000-0000-0000-000000000003', '2024-01-01', '2024-01-31', 12, 6, 2, 2800.00, 120.00, 1, 18, 32, 5, 16.7, 2800.00, 23.3),
('00000000-0000-0000-0000-000000000002', '2024-02-01', '2024-02-29', 18, 10, 4, 5800.00, 498.50, 3, 32, 58, 12, 22.2, 1933.33, 38.7),
('00000000-0000-0000-0000-000000000003', '2024-02-01', '2024-02-29', 14, 7, 3, 3600.00, 180.00, 2, 22, 38, 7, 21.4, 1800.00, 30.0);

-- Notifications personnalisées par utilisateur
INSERT INTO notifications (collaborator_id, title, message, type, priority, is_read, related_contact_id) VALUES
('00000000-0000-0000-0000-000000000002', 'Prospect senior très engagé', 'Françoise Dubois a ouvert votre email 2 fois. Score d''engagement : 78/100', 'high_engagement', 'high', false, '20000000-0000-0000-0000-000000000001'),
('00000000-0000-0000-0000-000000000002', 'Objectif mensuel en bonne voie', 'Vous avez atteint 38.7% de votre objectif annuel. Continuez !', 'target_progress', 'medium', false, NULL),
('00000000-0000-0000-0000-000000000003', 'Nouveau prospect à contacter', 'Michel Roux attend votre appel depuis 2 jours', 'follow_up_reminder', 'medium', false, '20000000-0000-0000-0000-000000000008'),
('00000000-0000-0000-0000-000000000001', 'Rapport hebdomadaire disponible', 'Le rapport de performance de l''équipe est prêt', 'report_ready', 'low', true, NULL);

-- =====================================================
-- 3. CRÉATION DES INDEX ET OPTIMISATIONS
-- =====================================================

-- Index pour les performances
CREATE INDEX idx_contacts_assigned_to ON contacts(assigned_to);
CREATE INDEX idx_contacts_status ON contacts(status);
CREATE INDEX idx_contacts_source ON contacts(source);
CREATE INDEX idx_contacts_engagement_score ON contacts(engagement_score);
CREATE INDEX idx_contracts_collaborator_id ON contracts(collaborator_id);
CREATE INDEX idx_contracts_status ON contracts(status);
CREATE INDEX idx_contracts_signature_date ON contracts(signature_date);
CREATE INDEX idx_interactions_collaborator_id ON interactions(collaborator_id);
CREATE INDEX idx_interactions_completed_at ON interactions(completed_at);
CREATE INDEX idx_emails_collaborator_id ON emails(collaborator_id);
CREATE INDEX idx_emails_status ON emails(status);
CREATE INDEX idx_notifications_collaborator_id ON notifications(collaborator_id);
CREATE INDEX idx_notifications_is_read ON notifications(is_read);
CREATE INDEX idx_user_kpis_collaborator_period ON user_kpis(collaborator_id, period_start, period_end);

-- =====================================================
-- 4. FONCTIONS ET TRIGGERS AVANCÉS
-- =====================================================

-- Fonction pour calculer automatiquement les KPI
CREATE OR REPLACE FUNCTION calculate_user_kpis(user_id UUID, start_date DATE, end_date DATE)
RETURNS TABLE(
    total_contacts_count INTEGER,
    new_prospects_count INTEGER,
    converted_clients_count INTEGER,
    total_revenue_amount DECIMAL,
    total_commission_amount DECIMAL,
    contracts_signed_count INTEGER,
    conversion_rate_calc DECIMAL,
    avg_deal_size_calc DECIMAL,
    target_achievement_calc DECIMAL
) AS $$
DECLARE
    target_value DECIMAL;
BEGIN
    -- Récupérer l'objectif de revenus
    SELECT st.target_value INTO target_value
    FROM sales_targets st
    WHERE st.collaborator_id = user_id 
    AND st.target_type = 'revenue'
    AND st.start_date <= start_date 
    AND st.end_date >= end_date
    LIMIT 1;

    RETURN QUERY
    SELECT 
        COUNT(DISTINCT c.id)::INTEGER as total_contacts_count,
        COUNT(DISTINCT CASE WHEN c.status = 'prospect' AND c.created_at BETWEEN start_date AND end_date THEN c.id END)::INTEGER as new_prospects_count,
        COUNT(DISTINCT CASE WHEN c.status = 'client' THEN c.id END)::INTEGER as converted_clients_count,
        COALESCE(SUM(ct.total_premium), 0)::DECIMAL as total_revenue_amount,
        COALESCE(SUM(ct.received_commission), 0)::DECIMAL as total_commission_amount,
        COUNT(DISTINCT ct.id)::INTEGER as contracts_signed_count,
        CASE 
            WHEN COUNT(DISTINCT CASE WHEN c.status = 'prospect' THEN c.id END) > 0 
            THEN (COUNT(DISTINCT CASE WHEN c.status = 'client' THEN c.id END)::DECIMAL / COUNT(DISTINCT CASE WHEN c.status = 'prospect' THEN c.id END)::DECIMAL * 100)
            ELSE 0 
        END as conversion_rate_calc,
        CASE 
            WHEN COUNT(DISTINCT ct.id) > 0 
            THEN (COALESCE(SUM(ct.total_premium), 0) / COUNT(DISTINCT ct.id))
            ELSE 0 
        END as avg_deal_size_calc,
        CASE 
            WHEN target_value > 0 
            THEN (COALESCE(SUM(ct.total_premium), 0) / target_value * 100)
            ELSE 0 
        END as target_achievement_calc
    FROM contacts c
    LEFT JOIN contracts ct ON c.id = ct.contact_id AND ct.signature_date BETWEEN start_date AND end_date
    WHERE c.assigned_to = user_id;
END;
$$ LANGUAGE plpgsql;

-- Fonction pour mettre à jour les scores d'engagement
CREATE OR REPLACE FUNCTION update_engagement_score()
RETURNS TRIGGER AS $$
BEGIN
    -- Augmenter le score lors d'une nouvelle interaction
    UPDATE contacts 
    SET engagement_score = LEAST(100, engagement_score + 
        CASE NEW.type
            WHEN 'call' THEN 15
            WHEN 'meeting' THEN 20
            WHEN 'email' THEN 5
            ELSE 10
        END),
        last_contact_date = NOW(),
        updated_at = NOW()
    WHERE id = NEW.contact_id;
    
    -- Créer une notification si le score dépasse 80
    IF (SELECT engagement_score FROM contacts WHERE id = NEW.contact_id) > 80 THEN
        INSERT INTO notifications (collaborator_id, title, message, type, priority, related_contact_id)
        SELECT 
            NEW.collaborator_id,
            'Prospect très engagé !',
            'Le prospect ' || c.first_name || ' ' || c.last_name || ' a un score d''engagement de ' || c.engagement_score || '/100',
            'high_engagement',
            'high',
            c.id
        FROM contacts c WHERE c.id = NEW.contact_id;
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger pour mettre à jour automatiquement les scores
CREATE TRIGGER trigger_update_engagement_score
    AFTER INSERT ON interactions
    FOR EACH ROW
    EXECUTE FUNCTION update_engagement_score();

-- Fonction pour calculer les commissions automatiquement
CREATE OR REPLACE FUNCTION calculate_commission()
RETURNS TRIGGER AS $$
BEGIN
    -- Calculer la commission basée sur le produit et le collaborateur
    NEW.received_commission := NEW.total_premium * (NEW.commission_rate / 100);
    
    -- Mettre à jour les KPI du collaborateur
    INSERT INTO user_kpis (collaborator_id, period_start, period_end, total_revenue, total_commission, contracts_signed)
    VALUES (
        NEW.collaborator_id,
        DATE_TRUNC('month', NEW.signature_date)::DATE,
        (DATE_TRUNC('month', NEW.signature_date) + INTERVAL '1 month - 1 day')::DATE,
        NEW.total_premium,
        NEW.received_commission,
        1
    )
    ON CONFLICT (collaborator_id, period_start, period_end)
    DO UPDATE SET
        total_revenue = user_kpis.total_revenue + NEW.total_premium,
        total_commission = user_kpis.total_commission + NEW.received_commission,
        contracts_signed = user_kpis.contracts_signed + 1,
        updated_at = NOW();
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger pour calculer automatiquement les commissions
CREATE TRIGGER trigger_calculate_commission
    BEFORE INSERT OR UPDATE ON contracts
    FOR EACH ROW
    WHEN (NEW.status = 'active')
    EXECUTE FUNCTION calculate_commission();

-- =====================================================
-- 5. VUES POUR LES RAPPORTS PERSONNALISÉS
-- =====================================================

-- Vue des performances par collaborateur
CREATE OR REPLACE VIEW v_collaborator_performance AS
SELECT 
    co.id,
    co.first_name || ' ' || co.last_name as full_name,
    co.email,
    co.role,
    co.department,
    COUNT(DISTINCT c.id) as total_contacts,
    COUNT(DISTINCT CASE WHEN c.status = 'prospect' THEN c.id END) as prospects_count,
    COUNT(DISTINCT CASE WHEN c.status = 'client' THEN c.id END) as clients_count,
    COUNT(DISTINCT ct.id) as contracts_count,
    COALESCE(SUM(ct.total_premium), 0) as total_revenue,
    COALESCE(SUM(ct.received_commission), 0) as total_commission,
    CASE 
        WHEN COUNT(DISTINCT CASE WHEN c.status = 'prospect' THEN c.id END) > 0 
        THEN ROUND((COUNT(DISTINCT CASE WHEN c.status = 'client' THEN c.id END)::DECIMAL / COUNT(DISTINCT CASE WHEN c.status = 'prospect' THEN c.id END)::DECIMAL * 100), 2)
        ELSE 0 
    END as conversion_rate,
    CASE 
        WHEN COUNT(DISTINCT ct.id) > 0 
        THEN ROUND((COALESCE(SUM(ct.total_premium), 0) / COUNT(DISTINCT ct.id)), 2)
        ELSE 0 
    END as avg_deal_size,
    COALESCE(st.target_value, 0) as annual_target,
    CASE 
        WHEN COALESCE(st.target_value, 0) > 0 
        THEN ROUND((COALESCE(SUM(ct.total_premium), 0) / st.target_value * 100), 2)
        ELSE 0 
    END as target_achievement
FROM collaborators co
LEFT JOIN contacts c ON co.id = c.assigned_to
LEFT JOIN contracts ct ON co.id = ct.collaborator_id AND ct.status = 'active'
LEFT JOIN sales_targets st ON co.id = st.collaborator_id AND st.target_type = 'revenue' AND st.status = 'active'
WHERE co.is_active = true
GROUP BY co.id, co.first_name, co.last_name, co.email, co.role, co.department, st.target_value;

-- Vue des prospects seniors Facebook
CREATE OR REPLACE VIEW v_senior_facebook_prospects AS
SELECT 
    c.*,
    co.first_name || ' ' || co.last_name as assigned_collaborator,
    EXTRACT(YEAR FROM AGE(c.birth_date)) as age,
    aes.score as ai_engagement_score,
    COUNT(i.id) as interactions_count,
    MAX(i.completed_at) as last_interaction,
    COUNT(e.id) as emails_sent,
    MAX(e.sent_at) as last_email_sent
FROM contacts c
LEFT JOIN collaborators co ON c.assigned_to = co.id
LEFT JOIN ai_engagement_scores aes ON c.id = aes.contact_id
LEFT JOIN interactions i ON c.id = i.contact_id
LEFT JOIN emails e ON c.id = e.contact_id
WHERE c.source = 'Facebook' 
AND c.birth_date < '1965-01-01'
AND c.phone IS NULL
GROUP BY c.id, co.first_name, co.last_name, aes.score;

-- Vue des KPI en temps réel
CREATE OR REPLACE VIEW v_realtime_kpis AS
SELECT 
    co.id as collaborator_id,
    co.first_name || ' ' || co.last_name as collaborator_name,
    co.role,
    -- KPI du mois en cours
    COUNT(DISTINCT CASE WHEN c.created_at >= DATE_TRUNC('month', CURRENT_DATE) THEN c.id END) as contacts_this_month,
    COUNT(DISTINCT CASE WHEN c.created_at >= DATE_TRUNC('month', CURRENT_DATE) AND c.status = 'prospect' THEN c.id END) as prospects_this_month,
    COUNT(DISTINCT CASE WHEN ct.signature_date >= DATE_TRUNC('month', CURRENT_DATE) THEN ct.id END) as contracts_this_month,
    COALESCE(SUM(CASE WHEN ct.signature_date >= DATE_TRUNC('month', CURRENT_DATE) THEN ct.total_premium END), 0) as revenue_this_month,
    -- KPI de l'année
    COUNT(DISTINCT CASE WHEN c.created_at >= DATE_TRUNC('year', CURRENT_DATE) THEN c.id END) as contacts_this_year,
    COUNT(DISTINCT CASE WHEN ct.signature_date >= DATE_TRUNC('year', CURRENT_DATE) THEN ct.id END) as contracts_this_year,
    COALESCE(SUM(CASE WHEN ct.signature_date >= DATE_TRUNC('year', CURRENT_DATE) THEN ct.total_premium END), 0) as revenue_this_year,
    -- Objectifs et performance
    COALESCE(st.target_value, 0) as annual_target,
    CASE 
        WHEN COALESCE(st.target_value, 0) > 0 
        THEN ROUND((COALESCE(SUM(CASE WHEN ct.signature_date >= DATE_TRUNC('year', CURRENT_DATE) THEN ct.total_premium END), 0) / st.target_value * 100), 2)
        ELSE 0 
    END as target_achievement_percent,
    -- Activité récente
    COUNT(DISTINCT CASE WHEN i.completed_at >= CURRENT_DATE - INTERVAL '7 days' THEN i.id END) as interactions_last_7_days,
    COUNT(DISTINCT CASE WHEN e.sent_at >= CURRENT_DATE - INTERVAL '7 days' THEN e.id END) as emails_last_7_days
FROM collaborators co
LEFT JOIN contacts c ON co.id = c.assigned_to
LEFT JOIN contracts ct ON co.id = ct.collaborator_id AND ct.status = 'active'
LEFT JOIN sales_targets st ON co.id = st.collaborator_id AND st.target_type = 'revenue' AND st.status = 'active'
LEFT JOIN interactions i ON co.id = i.collaborator_id
LEFT JOIN emails e ON co.id = e.collaborator_id
WHERE co.is_active = true AND co.role IN ('Commercial', 'Commercial Senior')
GROUP BY co.id, co.first_name, co.last_name, co.role, st.target_value;

-- =====================================================
-- 6. FONCTIONS POUR LES RAPPORTS AUTOMATISÉS
-- =====================================================

-- Fonction pour générer un rapport personnalisé
CREATE OR REPLACE FUNCTION generate_user_report(
    user_id UUID,
    report_type VARCHAR,
    start_date DATE DEFAULT NULL,
    end_date DATE DEFAULT NULL
)
RETURNS JSONB AS $$
DECLARE
    report_data JSONB;
    period_start DATE;
    period_end DATE;
BEGIN
    -- Définir les dates par défaut
    period_start := COALESCE(start_date, DATE_TRUNC('month', CURRENT_DATE)::DATE);
    period_end := COALESCE(end_date, CURRENT_DATE);
    
    CASE report_type
        WHEN 'performance' THEN
            SELECT jsonb_build_object(
                'period', jsonb_build_object('start', period_start, 'end', period_end),
                'contacts', jsonb_build_object(
                    'total', COUNT(DISTINCT c.id),
                    'prospects', COUNT(DISTINCT CASE WHEN c.status = 'prospect' THEN c.id END),
                    'clients', COUNT(DISTINCT CASE WHEN c.status = 'client' THEN c.id END)
                ),
                'revenue', jsonb_build_object(
                    'total', COALESCE(SUM(ct.total_premium), 0),
                    'commission', COALESCE(SUM(ct.received_commission), 0),
                    'contracts', COUNT(DISTINCT ct.id)
                ),
                'activity', jsonb_build_object(
                    'calls', COUNT(DISTINCT CASE WHEN i.type = 'call' THEN i.id END),
                    'emails', COUNT(DISTINCT CASE WHEN i.type = 'email' THEN i.id END),
                    'meetings', COUNT(DISTINCT CASE WHEN i.type = 'meeting' THEN i.id END)
                )
            ) INTO report_data
            FROM contacts c
            LEFT JOIN contracts ct ON c.id = ct.contact_id AND ct.signature_date BETWEEN period_start AND period_end
            LEFT JOIN interactions i ON c.id = i.contact_id AND i.completed_at BETWEEN period_start AND period_end
            WHERE c.assigned_to = user_id;
            
        WHEN 'senior_facebook' THEN
            SELECT jsonb_build_object(
                'period', jsonb_build_object('start', period_start, 'end', period_end),
                'prospects', jsonb_agg(
                    jsonb_build_object(
                        'name', c.first_name || ' ' || c.last_name,
                        'email', c.email,
                        'city', c.city,
                        'engagement_score', c.engagement_score,
                        'last_contact', c.last_contact_date,
                        'interactions_count', (SELECT COUNT(*) FROM interactions WHERE contact_id = c.id)
                    )
                ),
                'summary', jsonb_build_object(
                    'total_prospects', COUNT(*),
                    'avg_engagement', ROUND(AVG(c.engagement_score), 1),
                    'high_potential', COUNT(CASE WHEN c.engagement_score > 75 THEN 1 END)
                )
            ) INTO report_data
            FROM contacts c
            WHERE c.assigned_to = user_id 
            AND c.source = 'Facebook' 
            AND c.birth_date < '1965-01-01'
            AND c.phone IS NULL;
            
        ELSE
            report_data := '{"error": "Type de rapport non reconnu"}'::jsonb;
    END CASE;
    
    RETURN report_data;
END;
$$ LANGUAGE plpgsql;

-- =====================================================
-- 7. CONFIGURATION RLS (ROW LEVEL SECURITY)
-- =====================================================

-- Activer RLS sur toutes les tables sensibles
ALTER TABLE contacts ENABLE ROW LEVEL SECURITY;
ALTER TABLE contracts ENABLE ROW LEVEL SECURITY;
ALTER TABLE interactions ENABLE ROW LEVEL SECURITY;
ALTER TABLE emails ENABLE ROW LEVEL SECURITY;
ALTER TABLE notifications ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_kpis ENABLE ROW LEVEL SECURITY;
ALTER TABLE reports ENABLE ROW LEVEL SECURITY;

-- Politiques pour les contacts (chaque commercial voit ses contacts + directeur voit tout)
CREATE POLICY "Collaborators can view assigned contacts" ON contacts
    FOR ALL USING (
        assigned_to = auth.uid()::uuid OR 
        EXISTS (SELECT 1 FROM collaborators WHERE id = auth.uid()::uuid AND role = 'Directeur')
    );

-- Politiques pour les contrats
CREATE POLICY "Collaborators can view own contracts" ON contracts
    FOR ALL USING (
        collaborator_id = auth.uid()::uuid OR 
        EXISTS (SELECT 1 FROM collaborators WHERE id = auth.uid()::uuid AND role = 'Directeur')
    );

-- Politiques pour les interactions
CREATE POLICY "Collaborators can view own interactions" ON interactions
    FOR ALL USING (
        collaborator_id = auth.uid()::uuid OR 
        EXISTS (SELECT 1 FROM collaborators WHERE id = auth.uid()::uuid AND role = 'Directeur')
    );

-- Politiques pour les emails
CREATE POLICY "Collaborators can view own emails" ON emails
    FOR ALL USING (
        collaborator_id = auth.uid()::uuid OR 
        EXISTS (SELECT 1 FROM collaborators WHERE id = auth.uid()::uuid AND role = 'Directeur')
    );

-- Politiques pour les notifications (chaque utilisateur voit ses notifications)
CREATE POLICY "Users can view own notifications" ON notifications
    FOR ALL USING (collaborator_id = auth.uid()::uuid);

-- Politiques pour les KPI (chaque utilisateur voit ses KPI + directeur voit tout)
CREATE POLICY "Users can view own KPIs" ON user_kpis
    FOR ALL USING (
        collaborator_id = auth.uid()::uuid OR 
        EXISTS (SELECT 1 FROM collaborators WHERE id = auth.uid()::uuid AND role = 'Directeur')
    );

-- =====================================================
-- 8. DONNÉES DE TEST FINALES
-- =====================================================

-- Mise à jour des KPI actuels pour tous les commerciaux
DO $$
DECLARE
    collab RECORD;
    kpi_data RECORD;
BEGIN
    FOR collab IN SELECT id FROM collaborators WHERE role IN ('Commercial', 'Commercial Senior') LOOP
        SELECT * INTO kpi_data FROM calculate_user_kpis(
            collab.id, 
            DATE_TRUNC('month', CURRENT_DATE)::DATE,
            CURRENT_DATE
        );
        
        INSERT INTO user_kpis (
            collaborator_id, period_start, period_end,
            total_contacts, new_prospects, converted_clients,
            total_revenue, total_commission, contracts_signed,
            conversion_rate, avg_deal_size, target_achievement
        ) VALUES (
            collab.id,
            DATE_TRUNC('month', CURRENT_DATE)::DATE,
            (DATE_TRUNC('month', CURRENT_DATE) + INTERVAL '1 month - 1 day')::DATE,
            kpi_data.total_contacts_count,
            kpi_data.new_prospects_count,
            kpi_data.converted_clients_count,
            kpi_data.total_revenue_amount,
            kpi_data.total_commission_amount,
            kpi_data.contracts_signed_count,
            kpi_data.conversion_rate_calc,
            kpi_data.avg_deal_size_calc,
            kpi_data.target_achievement_calc
        ) ON CONFLICT (collaborator_id, period_start, period_end) DO UPDATE SET
            total_contacts = EXCLUDED.total_contacts,
            new_prospects = EXCLUDED.new_prospects,
            converted_clients = EXCLUDED.converted_clients,
            total_revenue = EXCLUDED.total_revenue,
            total_commission = EXCLUDED.total_commission,
            contracts_signed = EXCLUDED.contracts_signed,
            conversion_rate = EXCLUDED.conversion_rate,
            avg_deal_size = EXCLUDED.avg_deal_size,
            target_achievement = EXCLUDED.target_achievement,
            updated_at = NOW();
    END LOOP;
END $$;

-- =====================================================
-- 9. VÉRIFICATION FINALE
-- =====================================================

-- Affichage des statistiques d'installation
SELECT 'INSTALLATION CRM PRO ASSURANCES TERMINÉE' as status;
SELECT '=============================================' as separator;
SELECT 'DONNÉES CRÉÉES :' as section;
SELECT COUNT(*) || ' collaborateurs' as collaborators FROM collaborators;
SELECT COUNT(*) || ' produits d''assurance' as products FROM insurance_products;
SELECT COUNT(*) || ' contacts (dont ' || COUNT(CASE WHEN source = 'Facebook' AND birth_date < '1965-01-01' THEN 1 END) || ' seniors Facebook)' as contacts FROM contacts;
SELECT COUNT(*) || ' templates d''email spécialisés' as templates FROM email_templates;
SELECT COUNT(*) || ' workflows d''automatisation' as workflows FROM workflows;
SELECT COUNT(*) || ' contrats actifs' as contracts FROM contracts WHERE status = 'active';
SELECT COUNT(*) || ' interactions enregistrées' as interactions FROM interactions;
SELECT COUNT(*) || ' emails envoyés' as emails FROM emails;
SELECT COUNT(*) || ' notifications' as notifications FROM notifications;
SELECT COUNT(*) || ' scores IA calculés' as ai_scores FROM ai_engagement_scores;
SELECT '=============================================' as separator;
SELECT 'COMPTES DE TEST CRÉÉS :' as section;
SELECT email || ' (mot de passe: 123456789)' as login_info FROM collaborators ORDER BY role, first_name;
SELECT '=============================================' as separator;
SELECT 'SYSTÈME PRÊT À L''UTILISATION !' as final_status;
