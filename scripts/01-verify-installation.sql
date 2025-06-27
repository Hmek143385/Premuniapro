-- =====================================================
-- SCRIPT DE VÉRIFICATION DE L'INSTALLATION
-- =====================================================

-- Vérifier que toutes les tables ont été créées
SELECT 
    schemaname,
    tablename,
    tableowner
FROM pg_tables 
WHERE schemaname = 'public' 
ORDER BY tablename;

-- Vérifier le contenu des tables principales
SELECT 'COLLABORATORS' as table_name, COUNT(*) as count FROM collaborators
UNION ALL
SELECT 'CONTACTS', COUNT(*) FROM contacts
UNION ALL
SELECT 'PRODUCTS', COUNT(*) FROM products
UNION ALL
SELECT 'EMAIL_TEMPLATES', COUNT(*) FROM email_templates
UNION ALL
SELECT 'EMAIL_WORKFLOWS', COUNT(*) FROM email_workflows
UNION ALL
SELECT 'CONTRACTS', COUNT(*) FROM contracts
UNION ALL
SELECT 'INTERACTIONS', COUNT(*) FROM interactions
UNION ALL
SELECT 'EMAILS', COUNT(*) FROM emails
UNION ALL
SELECT 'NOTIFICATIONS', COUNT(*) FROM notifications;

-- Vérifier les prospects seniors Facebook
SELECT 
    first_name,
    last_name,
    email,
    source,
    phone,
    engagement_score,
    notes
FROM contacts 
WHERE source = 'Facebook' 
AND calculate_age(birth_date) >= 60;

-- Vérifier les templates d'email
SELECT 
    name,
    subject,
    category,
    target_audience
FROM email_templates
ORDER BY name;

-- Vérifier les workflows
SELECT 
    name,
    description,
    is_active
FROM email_workflows;

-- Statistiques par collaborateur
SELECT * FROM v_collaborator_stats;

-- Contacts avec le plus d'engagement
SELECT 
    first_name,
    last_name,
    email,
    source,
    engagement_score,
    status
FROM contacts 
ORDER BY engagement_score DESC 
LIMIT 10;
