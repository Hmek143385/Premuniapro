-- Insertion des rôles utilisateurs
INSERT INTO user_roles (id, name, description, permissions) VALUES
('11111111-1111-1111-1111-111111111111', 'Directeur', 'Accès complet à toutes les fonctionnalités', '{"all": true, "manage_users": true, "view_all_data": true, "set_targets": true}'),
('22222222-2222-2222-2222-222222222222', 'Commercial', 'Accès aux contacts et interactions', '{"view_own_data": true, "manage_contacts": true, "view_targets": true}'),
('33333333-3333-3333-3333-333333333333', 'Service Qualité', 'Accès aux rapports et feedbacks', '{"view_reports": true, "view_quality_data": true}'),
('44444444-4444-4444-4444-444444444444', 'Gestion', 'Accès aux contacts et rapports', '{"view_contacts": true, "view_reports": true}');

-- Insertion des collaborateurs
INSERT INTO collaborators (id, first_name, last_name, email, phone, password_hash, role_id, commission_rate, hire_date) VALUES
('00000000-0000-0000-0000-000000000001', 'Jean', 'Dupont', 'jean.dupont@crmPro.com', '0123456789', '$2b$10$hash123456789', '11111111-1111-1111-1111-111111111111', 15.00, '2023-01-15'),
('00000000-0000-0000-0000-000000000002', 'Marie', 'Martin', 'marie.martin@crmPro.com', '0123456790', '$2b$10$hash123456789', '22222222-2222-2222-2222-222222222222', 12.00, '2023-02-01'),
('00000000-0000-0000-0000-000000000003', 'Pierre', 'Durand', 'pierre.durand@crmPro.com', '0123456791', '$2b$10$hash123456789', '22222222-2222-2222-2222-222222222222', 12.00, '2023-03-01'),
('00000000-0000-0000-0000-000000000004', 'Sophie', 'Leroy', 'sophie.leroy@crmPro.com', '0123456792', '$2b$10$hash123456789', '33333333-3333-3333-3333-333333333333', 0.00, '2023-04-01'),
('00000000-0000-0000-0000-000000000005', 'Thomas', 'Moreau', 'thomas.moreau@crmPro.com', '0123456793', '$2b$10$hash123456789', '44444444-4444-4444-4444-444444444444', 0.00, '2023-05-01');

-- Insertion des produits d'assurance
INSERT INTO insurance_products (id, name, category, description, base_premium, commission_rate, min_age, max_age, coverage_amount) VALUES
('10000000-0000-0000-0000-000000000001', 'Assurance Vie Senior', 'Vie', 'Assurance vie adaptée aux seniors', 1200.00, 15.00, 50, 85, 50000.00),
('10000000-0000-0000-0000-000000000002', 'Assurance Santé Premium', 'Santé', 'Couverture santé complète', 800.00, 12.00, 18, 75, 100000.00),
('10000000-0000-0000-0000-000000000003', 'Assurance Auto Tous Risques', 'Auto', 'Protection automobile complète', 600.00, 10.00, 18, 80, 25000.00),
('10000000-0000-0000-0000-000000000004', 'Assurance Habitation', 'Habitation', 'Protection du domicile', 400.00, 8.00, 18, 99, 200000.00),
('10000000-0000-0000-0000-000000000005', 'Assurance Voyage Senior', 'Voyage', 'Couverture voyage pour seniors', 150.00, 20.00, 50, 85, 50000.00);

-- Insertion des contacts avec profils variés
INSERT INTO contacts (id, client_code, first_name, last_name, email, phone, birth_date, gender, address, postal_code, city, source, status, regime, commercial_id, assigned_to, ai_engagement_score) VALUES
-- Prospects seniors Facebook
('20000000-0000-0000-0000-000000000001', 'FB001', 'Robert', 'Dubois', 'robert.dubois@email.com', '0145678901', '1955-03-15', 'M', '12 rue de la Paix', '75001', 'Paris', 'Facebook', 'prospect', 'retraite', 'COM001', '00000000-0000-0000-0000-000000000002', 75),
('20000000-0000-0000-0000-000000000002', 'FB002', 'Françoise', 'Lemoine', 'francoise.lemoine@email.com', '0145678902', '1958-07-22', 'F', '25 avenue Victor Hugo', '69001', 'Lyon', 'Facebook', 'prospect', 'retraite', 'COM002', '00000000-0000-0000-0000-000000000002', 68),
('20000000-0000-0000-0000-000000000003', 'FB003', 'Michel', 'Rousseau', 'michel.rousseau@email.com', '0145678903', '1952-11-08', 'M', '8 place de la République', '13001', 'Marseille', 'Facebook', 'prospect', 'retraite', 'COM003', '00000000-0000-0000-0000-000000000003', 82),
('20000000-0000-0000-0000-000000000004', 'FB004', 'Monique', 'Garnier', 'monique.garnier@email.com', '0145678904', '1960-01-30', 'F', '15 rue du Commerce', '33000', 'Bordeaux', 'Facebook', 'prospect', 'retraite', 'COM004', '00000000-0000-0000-0000-000000000002', 71),
('20000000-0000-0000-0000-000000000005', 'FB005', 'André', 'Faure', 'andre.faure@email.com', '0145678905', '1954-09-12', 'M', '30 boulevard Saint-Germain', '31000', 'Toulouse', 'Facebook', 'prospect', 'retraite', 'COM005', '00000000-0000-0000-0000-000000000003', 79),
('20000000-0000-0000-0000-000000000006', 'FB006', 'Jacqueline', 'Mercier', 'jacqueline.mercier@email.com', '0145678906', '1957-05-18', 'F', '22 rue de Rivoli', '59000', 'Lille', 'Facebook', 'prospect', 'retraite', 'COM006', '00000000-0000-0000-0000-000000000002', 65),
('20000000-0000-0000-0000-000000000007', 'FB007', 'Claude', 'Blanc', 'claude.blanc@email.com', '0145678907', '1953-12-03', 'M', '18 avenue de la Liberté', '67000', 'Strasbourg', 'Facebook', 'prospect', 'retraite', 'COM007', '00000000-0000-0000-0000-000000000003', 73),
('20000000-0000-0000-0000-000000000008', 'FB008', 'Denise', 'Roux', 'denise.roux@email.com', '0145678908', '1959-04-25', 'F', '5 place Bellecour', '44000', 'Nantes', 'Facebook', 'prospect', 'retraite', 'COM008', '00000000-0000-0000-0000-000000000002', 77),

-- Prospects jeunes actifs
('20000000-0000-0000-0000-000000000009', 'WEB001', 'Julien', 'Moreau', 'julien.moreau@email.com', '0145678909', '1985-06-10', 'M', '45 rue de la Gare', '75010', 'Paris', 'Site Web', 'prospect', 'salarie', 'COM009', '00000000-0000-0000-0000-000000000002', 85),
('20000000-0000-0000-0000-000000000010', 'WEB002', 'Camille', 'Petit', 'camille.petit@email.com', '0145678910', '1990-02-14', 'F', '12 avenue des Champs', '69002', 'Lyon', 'Site Web', 'prospect', 'salarie', 'COM010', '00000000-0000-0000-0000-000000000003', 78),

-- Clients existants
('20000000-0000-0000-0000-000000000011', 'CLI001', 'Philippe', 'Bernard', 'philippe.bernard@email.com', '0145678911', '1965-08-20', 'M', '33 rue de la Mairie', '75015', 'Paris', 'Recommandation', 'client', 'retraite', 'COM011', '00000000-0000-0000-0000-000000000002', 92),
('20000000-0000-0000-0000-000000000012', 'CLI002', 'Isabelle', 'Girard', 'isabelle.girard@email.com', '0145678912', '1970-12-05', 'F', '7 place du Marché', '13002', 'Marseille', 'Recommandation', 'client', 'salarie', 'COM012', '00000000-0000-0000-0000-000000000003', 88);

-- Insertion des comptes email
INSERT INTO email_accounts (id, collaborator_id, email_address, provider, is_active) VALUES
('30000000-0000-0000-0000-000000000001', '00000000-0000-0000-0000-000000000001', 'jean.dupont@crmPro.com', 'gmail', true),
('30000000-0000-0000-0000-000000000002', '00000000-0000-0000-0000-000000000002', 'marie.martin@crmPro.com', 'outlook', true),
('30000000-0000-0000-0000-000000000003', '00000000-0000-0000-0000-000000000003', 'pierre.durand@crmPro.com', 'gmail', true);

-- Insertion des templates d'email
INSERT INTO email_templates (id, name, category, subject, body, variables, created_by) VALUES
('40000000-0000-0000-0000-000000000001', 'Relance Senior FB - Premier contact', 'Relance', 'Votre demande d''information sur nos assurances', 
'Bonjour {{first_name}},

Suite à votre demande d''information sur Facebook concernant nos solutions d''assurance, je me permets de vous recontacter.

En tant que spécialiste des assurances pour les seniors, je comprends l''importance de bien protéger votre famille et votre patrimoine à cette étape de votre vie.

J''aimerais vous proposer un rendez-vous téléphonique de 15 minutes pour :
- Comprendre vos besoins spécifiques
- Vous présenter nos solutions adaptées aux retraités
- Répondre à toutes vos questions sans engagement

Seriez-vous disponible cette semaine pour un échange ? Je peux vous appeler au moment qui vous convient le mieux.

Cordialement,
{{collaborator_name}}
{{collaborator_phone}}', 
'["first_name", "collaborator_name", "collaborator_phone"]', '00000000-0000-0000-0000-000000000001'),

('40000000-0000-0000-0000-000000000002', 'Relance Senior FB - Deuxième contact', 'Relance', 'N''oubliez pas votre protection retraite', 
'Bonjour {{first_name}},

Il y a quelques jours, vous aviez manifesté votre intérêt pour nos solutions d''assurance adaptées aux seniors.

Je sais combien il peut être difficile de s''y retrouver parmi toutes les offres du marché. C''est pourquoi je souhaite vous accompagner personnellement dans cette démarche importante.

Nos clients retraités apprécient particulièrement :
✓ Des conseillers dédiés qui prennent le temps d''expliquer
✓ Des tarifs préférentiels pour les seniors
✓ Un service client disponible et à l''écoute

Puis-je vous proposer un rendez-vous cette semaine ? Même 10 minutes suffisent pour faire le point sur vos besoins.

Bien à vous,
{{collaborator_name}}
Votre conseiller dédié', 
'["first_name", "collaborator_name"]', '00000000-0000-0000-0000-000000000001'),

('40000000-0000-0000-0000-000000000003', 'Relance Senior FB - Dernier contact', 'Relance', 'Dernière chance : votre devis personnalisé vous attend', 
'Bonjour {{first_name}},

C''est la dernière fois que je vous contacte concernant votre demande d''information sur nos assurances.

Je ne voudrais pas que vous passiez à côté d''une opportunité de mieux protéger votre famille, surtout avec les tarifs préférentiels que nous réservons aux nouveaux clients seniors ce mois-ci.

Si vous souhaitez toujours en savoir plus, je reste disponible jusqu''à vendredi pour vous proposer un devis personnalisé et sans engagement.

Un simple appel suffit : {{collaborator_phone}}

Prenez soin de vous,
{{collaborator_name}}', 
'["first_name", "collaborator_name", "collaborator_phone"]', '00000000-0000-0000-0000-000000000001'),

('40000000-0000-0000-0000-000000000004', 'Bienvenue Nouveau Prospect', 'Bienvenue', 'Bienvenue chez CRM Pro Assurances', 
'Bonjour {{first_name}},

Bienvenue et merci pour votre intérêt pour nos solutions d''assurance !

Votre demande a bien été enregistrée et un de nos conseillers spécialisés va prendre contact avec vous dans les 24 heures.

En attendant, n''hésitez pas à consulter notre guide gratuit "Bien choisir son assurance" disponible sur notre site.

À très bientôt,
L''équipe CRM Pro', 
'["first_name"]', '00000000-0000-0000-0000-000000000001'),

('40000000-0000-0000-0000-000000000005', 'Suivi Post-Signature', 'Suivi', 'Félicitations pour votre nouveau contrat !', 
'Bonjour {{first_name}},

Félicitations ! Votre contrat {{product_name}} est maintenant actif.

Vous recevrez sous 48h :
- Vos conditions générales
- Votre carte de tiers payant (si applicable)
- Vos identifiants espace client

Pour toute question, je reste à votre disposition.

Cordialement,
{{collaborator_name}}', 
'["first_name", "product_name", "collaborator_name"]', '00000000-0000-0000-0000-000000000001');

-- Insertion des workflows
INSERT INTO workflows (id, name, description, trigger_type, trigger_conditions, actions, created_by) VALUES
('50000000-0000-0000-0000-000000000001', 'Relance Prospects Seniors Facebook', 'Workflow de relance automatique pour les prospects seniors issus de Facebook', 'contact_created', 
'{"source": "Facebook", "status": "prospect", "age_min": 50}',
'[
  {"type": "wait", "duration": "1 day"},
  {"type": "send_email", "template_id": "40000000-0000-0000-0000-000000000001"},
  {"type": "wait", "duration": "3 days"},
  {"type": "send_email", "template_id": "40000000-0000-0000-0000-000000000002"},
  {"type": "wait", "duration": "5 days"},
  {"type": "send_email", "template_id": "40000000-0000-0000-0000-000000000003"},
  {"type": "create_task", "title": "Appel de relance final", "due_date": "+1 day"}
]', '00000000-0000-0000-0000-000000000001'),

('50000000-0000-0000-0000-000000000002', 'Bienvenue Nouveaux Prospects', 'Workflow d''accueil pour tous les nouveaux prospects', 'contact_created',
'{"status": "prospect"}',
'[
  {"type": "send_email", "template_id": "40000000-0000-0000-0000-000000000004"},
  {"type": "create_notification", "title": "Nouveau prospect", "message": "Un nouveau prospect a été créé"},
  {"type": "create_task", "title": "Premier contact", "due_date": "+1 day"}
]', '00000000-0000-0000-0000-000000000001'),

('50000000-0000-0000-0000-000000000003', 'Suivi Prospects Inactifs', 'Relance hebdomadaire des prospects sans interaction', 'scheduled',
'{"frequency": "weekly", "condition": "no_interaction_7_days"}',
'[
  {"type": "send_email", "template_id": "40000000-0000-0000-0000-000000000002"},
  {"type": "update_score", "action": "decrease", "value": 5}
]', '00000000-0000-0000-0000-000000000001');

-- Insertion des objectifs de vente
INSERT INTO sales_targets (id, collaborator_id, target_type, target_value, min_value, start_date, end_date, weight) VALUES
('60000000-0000-0000-0000-000000000001', '00000000-0000-0000-0000-000000000002', 'revenue', 50000.00, 35000.00, '2024-01-01', '2024-12-31', 40.00),
('60000000-0000-0000-0000-000000000002', '00000000-0000-0000-0000-000000000002', 'contracts', 25.00, 18.00, '2024-01-01', '2024-12-31', 35.00),
('60000000-0000-0000-0000-000000000003', '00000000-0000-0000-0000-000000000002', 'leads', 100.00, 75.00, '2024-01-01', '2024-12-31', 25.00),
('60000000-0000-0000-0000-000000000004', '00000000-0000-0000-0000-000000000003', 'revenue', 45000.00, 30000.00, '2024-01-01', '2024-12-31', 50.00),
('60000000-0000-0000-0000-000000000005', '00000000-0000-0000-0000-000000000003', 'contracts', 20.00, 15.00, '2024-01-01', '2024-12-31', 50.00);

-- Insertion des KPI personnalisés
INSERT INTO custom_kpis (id, name, description, formula, target_value, collaborator_id) VALUES
('70000000-0000-0000-0000-000000000001', 'Taux de conversion', 'Pourcentage de prospects convertis en clients', 'SELECT (COUNT(CASE WHEN status = ''client'' THEN 1 END) * 100.0 / COUNT(*)) FROM contacts WHERE assigned_to = $1', 15.00, '00000000-0000-0000-0000-000000000002'),
('70000000-0000-0000-0000-000000000002', 'Panier moyen', 'Montant moyen des contrats signés', 'SELECT AVG(premium_amount) FROM contracts WHERE collaborator_id = $1 AND status = ''active''', 2000.00, '00000000-0000-0000-0000-000000000002'),
('70000000-0000-0000-0000-000000000003', 'Temps de conversion', 'Nombre de jours moyen entre prospect et client', 'SELECT AVG(EXTRACT(DAY FROM c.signed_date - co.created_at)) FROM contracts c JOIN contacts co ON c.contact_id = co.id WHERE c.collaborator_id = $1', 30.00, '00000000-0000-0000-0000-000000000002');

-- Insertion des rapports automatiques
INSERT INTO reports (id, name, description, report_type, parameters, schedule, recipients, created_by) VALUES
('80000000-0000-0000-0000-000000000001', 'Rapport Hebdomadaire des Ventes', 'Rapport automatique des performances de vente', 'sales', 
'{"period": "week", "include_targets": true, "include_conversion": true}',
'{"frequency": "weekly", "day": "monday", "time": "09:00"}',
'{"00000000-0000-0000-0000-000000000001", "00000000-0000-0000-0000-000000000002"}', '00000000-0000-0000-0000-000000000001'),

('80000000-0000-0000-0000-000000000002', 'Rapport Mensuel de Performance', 'Analyse complète des performances mensuelles', 'performance',
'{"period": "month", "include_kpis": true, "include_forecasting": true}',
'{"frequency": "monthly", "day": 1, "time": "08:00"}',
'{"00000000-0000-0000-0000-000000000001"}', '00000000-0000-0000-0000-000000000001'),

('80000000-0000-0000-0000-000000000003', 'Analyse Cross-Selling', 'Opportunités de vente croisée identifiées par IA', 'cross_selling',
'{"ai_threshold": 0.7, "include_recommendations": true}',
'{"frequency": "weekly", "day": "friday", "time": "14:00"}',
'{"00000000-0000-0000-0000-000000000001", "00000000-0000-0000-0000-000000000002", "00000000-0000-0000-0000-000000000003"}', '00000000-0000-0000-0000-000000000001');

-- Insertion des contrats
INSERT INTO contracts (id, contract_number, contact_id, product_id, collaborator_id, status, premium_amount, commission_amount, start_date, end_date, signed_date) VALUES
('90000000-0000-0000-0000-000000000001', 'CTR-2024-001', '20000000-0000-0000-0000-000000000011', '10000000-0000-0000-0000-000000000001', '00000000-0000-0000-0000-000000000002', 'active', 1200.00, 180.00, '2024-01-15', '2025-01-15', '2024-01-10'),
('90000000-0000-0000-0000-000000000002', 'CTR-2024-002', '20000000-0000-0000-0000-000000000012', '10000000-0000-0000-0000-000000000002', '00000000-0000-0000-0000-000000000003', 'active', 800.00, 96.00, '2024-02-01', '2025-02-01', '2024-01-28');

-- Insertion des interactions
INSERT INTO interactions (id, contact_id, collaborator_id, type, subject, description, outcome, next_action, next_action_date) VALUES
('A0000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000001', '00000000-0000-0000-0000-000000000002', 'call', 'Premier contact suite Facebook', 'Appel de prise de contact suite à sa demande sur Facebook. Intéressé par assurance vie.', 'Intéressé', 'Envoyer devis personnalisé', '2024-01-20'),
('A0000000-0000-0000-0000-000000000002', '20000000-0000-0000-0000-000000000002', '00000000-0000-0000-0000-000000000002', 'email', 'Envoi documentation', 'Envoi de la documentation sur l''assurance santé senior', 'Documentation envoyée', 'Relance téléphonique', '2024-01-22'),
('A0000000-0000-0000-0000-000000000003', '20000000-0000-0000-0000-000000000003', '00000000-0000-0000-0000-000000000003', 'meeting', 'Rendez-vous de présentation', 'RDV en agence pour présentation des produits', 'Très intéressé', 'Préparer proposition commerciale', '2024-01-25'),
('A0000000-0000-0000-0000-000000000004', '20000000-0000-0000-0000-000000000009', '00000000-0000-0000-0000-000000000002', 'call', 'Appel de qualification', 'Qualification des besoins en assurance auto', 'Qualifié', 'Envoyer devis auto', '2024-01-21'),
('A0000000-0000-0000-0000-000000000005', '20000000-0000-0000-0000-000000000011', '00000000-0000-0000-0000-000000000002', 'meeting', 'Signature contrat', 'Signature du contrat d''assurance vie', 'Contrat signé', 'Suivi post-signature', '2024-02-10');

-- Insertion des emails
INSERT INTO emails (id, contact_id, collaborator_id, email_account_id, from_email, to_email, subject, body, email_type, status, sent_at) VALUES
('B0000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000001', '00000000-0000-0000-0000-000000000002', '30000000-0000-0000-0000-000000000002', 'marie.martin@crmPro.com', 'robert.dubois@email.com', 'Votre demande d''information sur nos assurances', 'Bonjour Robert, Suite à votre demande...', 'outbound', 'sent', '2024-01-15 10:30:00'),
('B0000000-0000-0000-0000-000000000002', '20000000-0000-0000-0000-000000000002', '00000000-0000-0000-0000-000000000002', '30000000-0000-0000-0000-000000000002', 'marie.martin@crmPro.com', 'francoise.lemoine@email.com', 'N''oubliez pas votre protection retraite', 'Bonjour Françoise, Il y a quelques jours...', 'outbound', 'sent', '2024-01-18 14:15:00'),
('B0000000-0000-0000-0000-000000000003', '20000000-0000-0000-0000-000000000009', '00000000-0000-0000-0000-000000000002', '30000000-0000-0000-0000-000000000002', 'marie.martin@crmPro.com', 'julien.moreau@email.com', 'Bienvenue chez CRM Pro Assurances', 'Bonjour Julien, Bienvenue et merci...', 'outbound', 'sent', '2024-01-16 09:00:00');

-- Insertion des notifications
INSERT INTO notifications (id, collaborator_id, title, message, type, priority) VALUES
('C0000000-0000-0000-0000-000000000001', '00000000-0000-0000-0000-000000000002', 'Nouveau prospect Facebook', 'Robert Dubois (FB001) a été ajouté comme prospect', 'contact_created', 'medium'),
('C0000000-0000-0000-0000-000000000002', '00000000-0000-0000-0000-000000000001', 'Objectif atteint', 'Marie Martin a atteint 80% de son objectif mensuel', 'target_progress', 'high'),
('C0000000-0000-0000-0000-000000000003', '00000000-0000-0000-0000-000000000003', 'Contrat signé', 'Nouveau contrat signé par Philippe Bernard', 'contract_signed', 'high'),
('C0000000-0000-0000-0000-000000000004', '00000000-0000-0000-0000-000000000002', 'Relance automatique', 'Email de relance envoyé à Françoise Lemoine', 'email_sent', 'low'),
('C0000000-0000-0000-0000-000000000005', '00000000-0000-0000-0000-000000000001', 'Rapport généré', 'Rapport hebdomadaire des ventes disponible', 'report_generated', 'medium');

-- Insertion des suggestions IA
INSERT INTO ai_suggestions (id, contact_id, collaborator_id, suggestion_type, title, description, confidence_score) VALUES
('D0000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000001', '00000000-0000-0000-0000-000000000002', 'cross_sell', 'Assurance Habitation', 'Ce client pourrait être intéressé par une assurance habitation complémentaire', 85.5),
('D0000000-0000-0000-0000-000000000002', '20000000-0000-0000-0000-000000000011', '00000000-0000-0000-0000-000000000002', 'upsell', 'Augmentation couverture', 'Proposer une augmentation de la couverture vie de 50000€ à 75000€', 78.2),
('D0000000-0000-0000-0000-000000000003', '20000000-0000-0000-0000-000000000003', '00000000-0000-0000-0000-000000000003', 'retention', 'Risque de départ', 'Ce prospect n''a pas répondu depuis 10 jours, risque de perte', 92.1),
('D0000000-0000-0000-0000-000000000004', '20000000-0000-0000-0000-000000000009', '00000000-0000-0000-0000-000000000002', 'timing', 'Moment optimal', 'Meilleur moment pour contacter : mardi 14h-16h', 88.7);

-- Insertion des partages de contacts
INSERT INTO contact_shares (id, contact_id, shared_by, shared_with, permission_level, message) VALUES
('E0000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000001', '00000000-0000-0000-0000-000000000002', '00000000-0000-0000-0000-000000000003', 'read', 'Prospect senior intéressant, pourriez-vous faire le suivi ?'),
('E0000000-0000-0000-0000-000000000002', '20000000-0000-0000-0000-000000000009', '00000000-0000-0000-0000-000000000003', '00000000-0000-0000-0000-000000000002', 'write', 'Client potentiel pour assurance auto, à votre expertise !');

-- Insertion des exécutions de workflow
INSERT INTO workflow_executions (id, workflow_id, contact_id, trigger_data, status, started_at, completed_at) VALUES
('F0000000-0000-0000-0000-000000000001', '50000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000001', '{"source": "Facebook", "age": 69}', 'completed', '2024-01-15 08:00:00', '2024-01-15 08:05:00'),
('F0000000-0000-0000-0000-000000000002', '50000000-0000-0000-0000-000000000002', '20000000-0000-0000-0000-000000000009', '{"source": "Site Web"}', 'completed', '2024-01-16 09:00:00', '2024-01-16 09:02:00'),
('F0000000-0000-0000-0000-000000000003', '50000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000002', '{"source": "Facebook", "age": 66}', 'running', '2024-01-18 10:00:00', NULL);

-- Insertion des données de rapport
INSERT INTO report_data (id, report_id, data, period_start, period_end) VALUES
('G0000000-0000-0000-0000-000000000001', '80000000-0000-0000-0000-000000000001', 
'{"total_revenue": 25000, "total_contracts": 12, "conversion_rate": 18.5, "top_performer": "Marie Martin"}', 
'2024-01-01', '2024-01-07'),
('G0000000-0000-0000-0000-000000000002', '80000000-0000-0000-0000-000000000002',
'{"monthly_revenue": 85000, "target_achievement": 78.2, "new_prospects": 45, "kpi_scores": {"conversion": 16.8, "retention": 94.2}}',
'2024-01-01', '2024-01-31');

-- Mise à jour des scores d'engagement
UPDATE contacts SET ai_engagement_score = calculate_engagement_score(id);
