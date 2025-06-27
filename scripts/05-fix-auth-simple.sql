-- =====================================================
-- CORRECTION AUTHENTIFICATION - MÉTHODE SIMPLE
-- =====================================================

-- Activer l'extension pgcrypto si pas déjà fait
CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- Supprimer tous les utilisateurs de test existants
DELETE FROM auth.users WHERE email LIKE '%@crmPro.com';

-- Fonction pour créer un utilisateur avec mot de passe simple
CREATE OR REPLACE FUNCTION create_test_user(
  user_email TEXT,
  user_password TEXT,
  user_first_name TEXT,
  user_last_name TEXT,
  user_role TEXT
) RETURNS UUID AS $$
DECLARE
  user_id UUID;
BEGIN
  -- Générer un UUID pour l'utilisateur
  user_id := gen_random_uuid();
  
  -- Insérer dans auth.users
  INSERT INTO auth.users (
    instance_id,
    id,
    aud,
    role,
    email,
    encrypted_password,
    email_confirmed_at,
    created_at,
    updated_at,
    raw_app_meta_data,
    raw_user_meta_data,
    is_super_admin,
    confirmation_token,
    email_change,
    email_change_token_new,
    recovery_token
  ) VALUES (
    '00000000-0000-0000-0000-000000000000',
    user_id,
    'authenticated',
    'authenticated',
    user_email,
    crypt(user_password, gen_salt('bf')),
    NOW(),
    NOW(),
    NOW(),
    '{"provider":"email","providers":["email"]}',
    format('{"first_name":"%s","last_name":"%s","role":"%s"}', user_first_name, user_last_name, user_role)::jsonb,
    false,
    '',
    '',
    '',
    ''
  );
  
  -- Insérer dans auth.identities
  INSERT INTO auth.identities (
    id,
    user_id,
    identity_data,
    provider,
    last_sign_in_at,
    created_at,
    updated_at
  ) VALUES (
    gen_random_uuid(),
    user_id,
    format('{"sub":"%s","email":"%s"}', user_id, user_email)::jsonb,
    'email',
    NOW(),
    NOW(),
    NOW()
  );
  
  RETURN user_id;
END;
$$ LANGUAGE plpgsql;

-- Créer les utilisateurs de test
DO $$
DECLARE
  directeur_id UUID;
  commercial_senior_id UUID;
  commercial_id UUID;
  qualite_id UUID;
  gestionnaire_id UUID;
BEGIN
  -- Créer les utilisateurs
  directeur_id := create_test_user('jean.dupont@crmPro.com', 'directeur123', 'Jean', 'Dupont', 'Directeur');
  commercial_senior_id := create_test_user('marie.martin@crmPro.com', 'commercial123', 'Marie', 'Martin', 'Commercial Senior');
  commercial_id := create_test_user('pierre.durand@crmPro.com', 'commercial123', 'Pierre', 'Durand', 'Commercial');
  qualite_id := create_test_user('sophie.leroy@crmPro.com', 'qualite123', 'Sophie', 'Leroy', 'Service Qualité');
  gestionnaire_id := create_test_user('thomas.moreau@crmPro.com', 'gestion123', 'Thomas', 'Moreau', 'Gestionnaire');
  
  -- Mettre à jour les collaborateurs avec les auth_user_id
  UPDATE collaborators SET auth_user_id = directeur_id WHERE email = 'jean.dupont@crmPro.com';
  UPDATE collaborators SET auth_user_id = commercial_senior_id WHERE email = 'marie.martin@crmPro.com';
  UPDATE collaborators SET auth_user_id = commercial_id WHERE email = 'pierre.durand@crmPro.com';
  UPDATE collaborators SET auth_user_id = qualite_id WHERE email = 'sophie.leroy@crmPro.com';
  UPDATE collaborators SET auth_user_id = gestionnaire_id WHERE email = 'thomas.moreau@crmPro.com';
  
  RAISE NOTICE 'Utilisateurs créés avec succès !';
END $$;

-- Vérifier la création
SELECT 
  u.email as "📧 Email",
  CASE 
    WHEN u.email = 'jean.dupont@crmPro.com' THEN 'directeur123'
    WHEN u.email = 'marie.martin@crmPro.com' THEN 'commercial123'
    WHEN u.email = 'pierre.durand@crmPro.com' THEN 'commercial123'
    WHEN u.email = 'sophie.leroy@crmPro.com' THEN 'qualite123'
    WHEN u.email = 'thomas.moreau@crmPro.com' THEN 'gestion123'
  END as "🔑 Mot de passe",
  c.role as "👤 Rôle",
  CASE WHEN u.email_confirmed_at IS NOT NULL THEN '✅ Confirmé' ELSE '❌ Non confirmé' END as "Statut"
FROM auth.users u
LEFT JOIN collaborators c ON u.id = c.auth_user_id
WHERE u.email LIKE '%@crmPro.com'
ORDER BY u.email;

-- Nettoyer la fonction temporaire
DROP FUNCTION create_test_user(TEXT, TEXT, TEXT, TEXT, TEXT);

-- Message de succès
SELECT '🎉 AUTHENTIFICATION CONFIGURÉE AVEC SUCCÈS !' as "Résultat";
SELECT '🔐 Vous pouvez maintenant vous connecter avec les comptes ci-dessus' as "Instructions";
