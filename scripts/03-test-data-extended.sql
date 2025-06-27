-- Mise à jour des mots de passe pour tous les collaborateurs
UPDATE collaborators SET password_hash = '$2b$10$123456789' WHERE email LIKE '%@%';

-- Ajout de prospects seniors Facebook avec des profils réalistes
INSERT INTO contacts (first_name, last_name, birth_date, email, phone, city, postal_code, profession, source, status, assigned_to, family_situation) VALUES
('Robert', 'Dubois', '1955-03-15', 'robert.dubois@gmail.com', '0145678901', 'Paris', '75015', 'Retraité', 'Facebook', 'prospect', '00000000-0000-0000-0000-000000000002', 'Marié(e)'),
('Françoise', 'Martin', '1952-07-22', 'francoise.martin@orange.fr', '0234567890', 'Lyon', '69003', 'Retraité', 'Facebook', 'prospect', '00000000-0000-0000-0000-000000000002', 'Veuf/Veuve'),
('Michel', 'Leroy', '1948-11-08', 'michel.leroy@wanadoo.fr', '0345678901', 'Marseille', '13008', 'Retraité', 'Facebook', 'prospect', '00000000-0000-0000-0000-000000000003', 'Marié(e)'),
('Monique', 'Petit', '1950-05-30', 'monique.petit@free.fr', '0456789012', 'Toulouse', '31000', 'Retraité', 'Facebook', 'prospect', '00000000-0000-0000-0000-000000000002', 'Divorcé(e)'),
('Jean-Claude', 'Moreau', '1953-09-12', 'jc.moreau@gmail.com', '0567890123', 'Nice', '06000', 'Retraité', 'Facebook', 'prospect', '00000000-0000-0000-0000-000000000003', 'Marié(e)'),
('Sylvie', 'Roux', '1954-01-25', 'sylvie.roux@hotmail.com', '0678901234', 'Nantes', '44000', 'Retraité', 'Facebook', 'prospect', '00000000-0000-0000-0000-000000000002', 'Célibataire'),
('Bernard', 'Fournier', '1949-12-03', 'bernard.fournier@sfr.fr', '0789012345', 'Strasbourg', '67000', 'Retraité', 'Facebook', 'prospect', '00000000-0000-0000-0000-000000000003', 'Marié(e)'),
('Jacqueline', 'Girard', '1951-08-17', 'jacqueline.girard@gmail.com', '0890123456', 'Bordeaux', '33000', 'Retraité', 'Facebook', 'prospect', '00000000-0000-0000-0000-000000000002', 'Veuf/Veuve'),

-- Prospects jeunes actifs
('Amélie', 'Rousseau', '1985-04-12', 'amelie.rousseau@gmail.com', '0612345678', 'Paris', '75011', 'Ingénieur', 'Website', 'prospect', '00000000-0000-0000-0000-000000000002', 'Célibataire'),
('Thomas', 'Blanc', '1990-06-25', 'thomas.blanc@outlook.com', '0623456789', 'Lyon', '69001', 'Développeur', 'Google Ads', 'prospect', '00000000-0000-0000-0000-000000000003', 'Marié(e)'),
('Sarah', 'Mercier', '1988-02-14', 'sarah.mercier@yahoo.fr', '0634567890', 'Lille', '59000', 'Médecin', 'Recommandation', 'prospect', '00000000-0000-0000-0000-000000000002', 'Marié(e)'),
('Julien', 'Lefebvre', '1992-10-30', 'julien.lefebvre@gmail.com', '0645678901', 'Rennes', '35000', 'Professeur', 'Facebook', 'prospect', '00000000-0000-0000-0000-000000000003', 'Célibataire'),

-- Clients existants
('Marie', 'Durand', '1975-03-20', 'marie.durand@gmail.com', '0156789012', 'Paris', '75016', 'Cadre', 'Recommandation', 'client', '00000000-0000-0000-0000-000000000002', 'Marié(e)'),
('Pierre', 'Lemoine', '1970-11-15', 'pierre.lemoine@orange.fr', '0267890123', 'Versailles', '78000', 'Directeur', 'Website', 'client', '00000000-0000-0000-0000-000000000003', 'Marié(e)'),
('Catherine', 'Bonnet', '1965-07-08', 'catherine.bonnet@free.fr', '0378901234', 'Neuilly', '92200', 'Avocate', 'Recommandation', 'client', '00000000-0000-0000-0000-000000000002', 'Divorcé(e)');

-- Contrats pour les clients
INSERT INTO contracts (contact_id, product_id, full_name, city, signature_date, start_date, monthly_premium, annual_premium, status, assigned_to) 
SELECT 
    c.id,
    p.id,
    c.first_name || ' ' || c.last_name,
    c.city,
    CURRENT_DATE - INTERVAL '30 days',
    CURRENT_DATE - INTERVAL '30 days',
    p.base_price / 12,
    p.base_price,
    'active',
    c.assigned_to
FROM contacts c
CROSS JOIN insurance_products p
WHERE c.status = 'client' AND p.code IN ('VIE001', 'AUTO001', 'SANTE001')
LIMIT 5;

-- Interactions pour créer de l'historique
INSERT INTO interactions (contact_id, type, outcome, completed_at, duration_minutes, notes, collaborator_id) 
SELECT 
    c.id,
    CASE (random() * 3)::int
        WHEN 0 THEN 'call'
        WHEN 1 THEN 'email'
        ELSE 'meeting'
    END,
    CASE (random() * 4)::int
        WHEN 0 THEN 'Intéressé'
        WHEN 1 THEN 'À rappeler'
        WHEN 2 THEN 'Pas intéressé'
        ELSE 'Rendez-vous pris'
    END,
    NOW() - INTERVAL '1 day' * (random() * 30)::int,
    (15 + random() * 45)::int,
    'Contact établi, prospect ' || 
    CASE (random() * 3)::int
        WHEN 0 THEN 'très intéressé par nos solutions'
        WHEN 1 THEN 'demande plus d''informations'
        ELSE 'souhaite réfléchir'
    END,
    c.assigned_to
FROM contacts c
WHERE c.status IN ('prospect', 'client')
ORDER BY random()
LIMIT 25;

-- Emails de test
INSERT INTO emails (contact_id, collaborator_id, subject, body, from_email, to_email, email_type, status, sent_at) 
SELECT 
    c.id,
    c.assigned_to,
    'Suivi de votre demande d''information',
    'Bonjour ' || c.first_name || ', suite à notre échange, je vous envoie les informations demandées...',
    'commercial@crm-pro.com',
    c.email,
    'outbound',
    CASE (random() * 3)::int
        WHEN 0 THEN 'sent'
        WHEN 1 THEN 'delivered'
        ELSE 'opened'
    END,
    NOW() - INTERVAL '1 day' * (random() * 7)::int
FROM contacts c
WHERE c.email IS NOT NULL AND c.status = 'prospect'
ORDER BY random()
LIMIT 15;

-- Notifications de test
INSERT INTO notifications (collaborator_id, title, message, type, priority, is_read) VALUES
('00000000-0000-0000-0000-000000000002', 'Nouveau prospect senior', 'Robert Dubois (Facebook) attend votre appel', 'new_prospect', 'high', false),
('00000000-0000-0000-0000-000000000002', 'Relance à effectuer', 'Françoise Martin n''a pas répondu depuis 3 jours', 'follow_up_reminder', 'medium', false),
('00000000-0000-0000-0000-000000000003', 'Contrat signé', 'Marie Durand a signé son contrat Assurance Vie', 'contract_signed', 'high', true),
('00000000-0000-0000-0000-000000000002', 'Rendez-vous confirmé', 'Michel Leroy a confirmé son RDV pour demain 14h', 'appointment_confirmed', 'medium', false),
('00000000-0000-0000-0000-000000000003', 'Objectif atteint', 'Félicitations ! Vous avez atteint 80% de votre objectif mensuel', 'target_achievement', 'low', true);

-- Objectifs de vente
INSERT INTO sales_targets (collaborator_id, target_type, target_value, min_value, start_date, end_date, weight) VALUES
('00000000-0000-0000-0000-000000000002', 'revenue', 50000.00, 35000.00, '2024-01-01', '2024-12-31', 100),
('00000000-0000-0000-0000-000000000003', 'revenue', 45000.00, 30000.00, '2024-01-01', '2024-12-31', 100),
('00000000-0000-0000-0000-000000000002', 'contracts', 25, 15, '2024-01-01', '2024-12-31', 80),
('00000000-0000-0000-0000-000000000003', 'contracts', 20, 12, '2024-01-01', '2024-12-31', 80);

-- Scores d'engagement IA pour les prospects
INSERT INTO ai_engagement_scores (contact_id, score, factors, last_interaction_date, prediction_confidence, recommended_actions)
SELECT 
    c.id,
    (50 + random() * 50)::int,
    jsonb_build_object(
        'source', c.source,
        'interactions_count', (random() * 5)::int,
        'days_since_creation', EXTRACT(DAY FROM NOW() - c.created_at),
        'has_email', c.email IS NOT NULL,
        'has_phone', c.phone IS NOT NULL
    ),
    NOW() - INTERVAL '1 day' * (random() * 10)::int,
    0.75 + random() * 0.25,
    jsonb_build_array(
        'Programmer un appel de suivi',
        'Envoyer une proposition personnalisée',
        'Organiser une rencontre'
    )
FROM contacts c
WHERE c.status = 'prospect';

-- Suggestions IA
INSERT INTO ai_suggestions (contact_id, suggestion_type, title, description, confidence_score, priority, status)
SELECT 
    c.id,
    CASE (random() * 3)::int
        WHEN 0 THEN 'follow_up'
        WHEN 1 THEN 'cross_sell'
        ELSE 'action'
    END,
    CASE (random() * 3)::int
        WHEN 0 THEN 'Relance recommandée'
        WHEN 1 THEN 'Opportunité de vente croisée'
        ELSE 'Proposition commerciale'
    END,
    CASE (random() * 3)::int
        WHEN 0 THEN 'Ce prospect n''a pas eu d''interaction récente. Une relance serait bénéfique.'
        WHEN 1 THEN 'Ce client pourrait être intéressé par des produits complémentaires.'
        ELSE 'Ce prospect semble prêt pour une proposition commerciale.'
    END,
    0.6 + random() * 0.4,
    CASE (random() * 3)::int
        WHEN 0 THEN 'high'
        WHEN 1 THEN 'medium'
        ELSE 'low'
    END,
    'pending'
FROM contacts c
WHERE c.status IN ('prospect', 'client')
ORDER BY random()
LIMIT 20;
