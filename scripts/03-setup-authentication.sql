-- =====================================================
-- CONFIGURATION AUTHENTIFICATION SUPABASE
-- =====================================================

-- Activer l'authentification par email
UPDATE auth.config SET 
  site_url = 'http://localhost:3000',
  jwt_expiry = 3600,
  refresh_token_rotation_enabled = true,
  security_update_password_require_reauthentication = false;

-- Créer les utilisateurs d'authentification
-- IMPORTANT: Ces utilisateurs doivent être créés via l'interface Supabase Auth
-- ou via l'API Supabase Admin

-- Insérer les utilisateurs dans auth.users (simulation - à faire via Supabase Dashboard)
-- 1. jean.dupont@crmPro.com - Directeur - Mot de passe: directeur123
-- 2. marie.martin@crmPro.com - Commercial Senior - Mot de passe: commercial123  
-- 3. pierre.durand@crmPro.com - Commercial - Mot de passe: commercial123
-- 4. sophie.leroy@crmPro.com - Service Qualité - Mot de passe: qualite123
-- 5. thomas.moreau@crmPro.com - Gestionnaire - Mot de passe: gestion123

-- Mettre à jour la table collaborators pour lier avec auth.users
ALTER TABLE collaborators ADD COLUMN IF NOT EXISTS auth_user_id UUID REFERENCES auth.users(id);

-- Fonction pour synchroniser les utilisateurs
CREATE OR REPLACE FUNCTION sync_collaborator_with_auth()
RETURNS TRIGGER AS $$
BEGIN
  -- Lors de la création d'un utilisateur auth, créer ou mettre à jour le collaborateur
  INSERT INTO collaborators (
    id, 
    auth_user_id,
    first_name, 
    last_name, 
    email, 
    role,
    is_active
  ) VALUES (
    NEW.id,
    NEW.id,
    COALESCE(NEW.raw_user_meta_data->>'first_name', 'Prénom'),
    COALESCE(NEW.raw_user_meta_data->>'last_name', 'Nom'),
    NEW.email,
    COALESCE(NEW.raw_user_meta_data->>'role', 'Commercial'),
    true
  ) ON CONFLICT (email) DO UPDATE SET
    auth_user_id = NEW.id,
    updated_at = NOW();
    
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Trigger pour synchroniser automatiquement
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION sync_collaborator_with_auth();

-- Politique RLS mise à jour pour utiliser auth.uid()
DROP POLICY IF EXISTS "Collaborators can view assigned contacts" ON contacts;
CREATE POLICY "Collaborators can view assigned contacts" ON contacts
    FOR ALL USING (
        assigned_to IN (SELECT id FROM collaborators WHERE auth_user_id = auth.uid()) OR 
        EXISTS (SELECT 1 FROM collaborators WHERE auth_user_id = auth.uid() AND role = 'Directeur')
    );

-- Mettre à jour les collaborateurs existants avec des IDs fictifs pour les tests
UPDATE collaborators SET 
  auth_user_id = id,
  password_hash = crypt('directeur123', gen_salt('bf'))
WHERE email = 'jean.dupont@crmPro.com';

UPDATE collaborators SET 
  auth_user_id = id,
  password_hash = crypt('commercial123', gen_salt('bf'))
WHERE email = 'marie.martin@crmPro.com';

UPDATE collaborators SET 
  auth_user_id = id,
  password_hash = crypt('commercial123', gen_salt('bf'))
WHERE email = 'pierre.durand@crmPro.com';

UPDATE collaborators SET 
  auth_user_id = id,
  password_hash = crypt('qualite123', gen_salt('bf'))
WHERE email = 'sophie.leroy@crmPro.com';

UPDATE collaborators SET 
  auth_user_id = id,
  password_hash = crypt('gestion123', gen_salt('bf'))
WHERE email = 'thomas.moreau@crmPro.com';

-- Afficher les informations de connexion
SELECT 
  'COMPTES DE CONNEXION CRÉÉS:' as info,
  '' as separator;

SELECT 
  email as "Email de connexion",
  CASE 
    WHEN email = 'jean.dupont@crmPro.com' THEN 'directeur123'
    WHEN email = 'marie.martin@crmPro.com' THEN 'commercial123'
    WHEN email = 'pierre.durand@crmPro.com' THEN 'commercial123'
    WHEN email = 'sophie.leroy@crmPro.com' THEN 'qualite123'
    WHEN email = 'thomas.moreau@crmPro.com' THEN 'gestion123'
  END as "Mot de passe",
  role as "Rôle"
FROM collaborators 
ORDER BY role, first_name;
