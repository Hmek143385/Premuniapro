-- =====================================================
-- CRÉATION DES UTILISATEURS D'AUTHENTIFICATION
-- =====================================================

-- Supprimer les utilisateurs existants s'ils existent
DELETE FROM auth.users WHERE email IN (
  'jean.dupont@crmPro.com',
  'marie.martin@crmPro.com', 
  'pierre.durand@crmPro.com',
  'sophie.leroy@crmPro.com',
  'thomas.moreau@crmPro.com'
);

-- Créer les utilisateurs d'authentification directement
INSERT INTO auth.users (
  instance_id,
  id,
  aud,
  role,
  email,
  encrypted_password,
  email_confirmed_at,
  recovery_sent_at,
  last_sign_in_at,
  raw_app_meta_data,
  raw_user_meta_data,
  created_at,
  updated_at,
  confirmation_token,
  email_change,
  email_change_token_new,
  recovery_token
) VALUES 
-- Directeur
(
  '00000000-0000-0000-0000-000000000000',
  gen_random_uuid(),
  'authenticated',
  'authenticated',
  'jean.dupont@crmPro.com',
  crypt('directeur123', gen_salt('bf')),
  NOW(),
  NOW(),
  NOW(),
  '{"provider": "email", "providers": ["email"]}',
  '{"first_name": "Jean", "last_name": "Dupont", "role": "Directeur"}',
  NOW(),
  NOW(),
  '',
  '',
  '',
  ''
),
-- Commercial Senior
(
  '00000000-0000-0000-0000-000000000000',
  gen_random_uuid(),
  'authenticated',
  'authenticated',
  'marie.martin@crmPro.com',
  crypt('commercial123', gen_salt('bf')),
  NOW(),
  NOW(),
  NOW(),
  '{"provider": "email", "providers": ["email"]}',
  '{"first_name": "Marie", "last_name": "Martin", "role": "Commercial Senior"}',
  NOW(),
  NOW(),
  '',
  '',
  '',
  ''
),
-- Commercial
(
  '00000000-0000-0000-0000-000000000000',
  gen_random_uuid(),
  'authenticated',
  'authenticated',
  'pierre.durand@crmPro.com',
  crypt('commercial123', gen_salt('bf')),
  NOW(),
  NOW(),
  NOW(),
  '{"provider": "email", "providers": ["email"]}',
  '{"first_name": "Pierre", "last_name": "Durand", "role": "Commercial"}',
  NOW(),
  NOW(),
  '',
  '',
  '',
  ''
),
-- Service Qualité
(
  '00000000-0000-0000-0000-000000000000',
  gen_random_uuid(),
  'authenticated',
  'authenticated',
  'sophie.leroy@crmPro.com',
  crypt('qualite123', gen_salt('bf')),
  NOW(),
  NOW(),
  NOW(),
  '{"provider": "email", "providers": ["email"]}',
  '{"first_name": "Sophie", "last_name": "Leroy", "role": "Service Qualité"}',
  NOW(),
  NOW(),
  '',
  '',
  '',
  ''
),
-- Gestionnaire
(
  '00000000-0000-0000-0000-000000000000',
  gen_random_uuid(),
  'authenticated',
  'authenticated',
  'thomas.moreau@crmPro.com',
  crypt('gestion123', gen_salt('bf')),
  NOW(),
  NOW(),
  NOW(),
  '{"provider": "email", "providers": ["email"]}',
  '{"first_name": "Thomas", "last_name": "Moreau", "role": "Gestionnaire"}',
  NOW(),
  NOW(),
  '',
  '',
  '',
  ''
);

-- Mettre à jour les collaborateurs avec les IDs d'authentification
UPDATE collaborators SET auth_user_id = (
  SELECT id FROM auth.users WHERE email = collaborators.email
) WHERE email IN (
  'jean.dupont@crmPro.com',
  'marie.martin@crmPro.com', 
  'pierre.durand@crmPro.com',
  'sophie.leroy@crmPro.com',
  'thomas.moreau@crmPro.com'
);

-- Vérifier la création
SELECT 
  u.email,
  u.id as auth_id,
  c.first_name,
  c.last_name,
  c.role,
  'Utilisateur créé avec succès' as status
FROM auth.users u
JOIN collaborators c ON u.id = c.auth_user_id
WHERE u.email LIKE '%@crmPro.com'
ORDER BY c.role, c.first_name;

-- Afficher les informations de connexion
SELECT 
  '=== COMPTES DE CONNEXION CRÉÉS ===' as info;

SELECT 
  email as "📧 Email",
  CASE 
    WHEN email = 'jean.dupont@crmPro.com' THEN '🔑 directeur123'
    WHEN email = 'marie.martin@crmPro.com' THEN '🔑 commercial123'
    WHEN email = 'pierre.durand@crmPro.com' THEN '🔑 commercial123'
    WHEN email = 'sophie.leroy@crmPro.com' THEN '🔑 qualite123'
    WHEN email = 'thomas.moreau@crmPro.com' THEN '🔑 gestion123'
  END as "Mot de passe",
  '👤 ' || (SELECT role FROM collaborators WHERE auth_user_id = auth.users.id) as "Rôle"
FROM auth.users 
WHERE email LIKE '%@crmPro.com'
ORDER BY email;
