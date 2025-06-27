-- Insert sample collaborators
INSERT INTO collaborators (email, password_hash, first_name, last_name, role, commission_rate) VALUES
('admin@crm.com', '$2b$10$example_hash', 'Admin', 'User', 'admin', 0.0000),
('commercial1@crm.com', '$2b$10$example_hash', 'Jean', 'Dupont', 'commercial', 0.0500),
('commercial2@crm.com', '$2b$10$example_hash', 'Marie', 'Martin', 'commercial', 0.0450),
('manager@crm.com', '$2b$10$example_hash', 'Pierre', 'Durand', 'manager', 0.0300);

-- Insert sample insurance products
INSERT INTO insurance_products (code, name, category, base_price, commission_rate, cross_sell_priority) VALUES
('VIE001', 'Assurance Vie Premium', 'Vie', 1200.00, 0.0800, 1),
('AUTO001', 'Assurance Auto Complète', 'Automobile', 800.00, 0.0600, 2),
('SANTE001', 'Mutuelle Santé Famille', 'Santé', 450.00, 0.0700, 3),
('HABIT001', 'Assurance Habitation', 'Habitation', 350.00, 0.0500, 4),
('PROF001', 'Assurance Professionnelle', 'Professionnelle', 600.00, 0.0650, 5);

-- Insert sample contacts
INSERT INTO contacts (first_name, last_name, birth_date, email, phone, city, profession, source, status, assigned_to) 
SELECT 
    'Client' || generate_series,
    'Test' || generate_series,
    '1980-01-01'::date + (generate_series * 365) * interval '1 day',
    'client' || generate_series || '@test.com',
    '0123456' || LPAD(generate_series::text, 3, '0'),
    CASE (generate_series % 5)
        WHEN 0 THEN 'Paris'
        WHEN 1 THEN 'Lyon'
        WHEN 2 THEN 'Marseille'
        WHEN 3 THEN 'Toulouse'
        ELSE 'Nice'
    END,
    CASE (generate_series % 4)
        WHEN 0 THEN 'Ingénieur'
        WHEN 1 THEN 'Médecin'
        WHEN 2 THEN 'Professeur'
        ELSE 'Commerçant'
    END,
    'Website',
    CASE (generate_series % 3)
        WHEN 0 THEN 'prospect'
        WHEN 1 THEN 'client'
        ELSE 'lead'
    END,
    (SELECT id FROM collaborators WHERE role = 'commercial' ORDER BY RANDOM() LIMIT 1)
FROM generate_series(1, 20);
