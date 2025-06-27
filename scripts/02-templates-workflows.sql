-- Templates d'email pour prospects seniors Facebook
INSERT INTO email_templates (collaborator_id, name, subject, body, template_type, variables) VALUES
('00000000-0000-0000-0000-000000000001', 'Relance Prospect Senior FB - 1er contact', 'Suite à votre demande d''information', 
'Bonjour {{first_name}},

Suite à votre demande d''information sur Facebook concernant nos solutions d''assurance, j''espère que vous allez bien.

Je comprends qu''il peut être difficile de vous joindre par téléphone, c''est pourquoi je vous propose de planifier un rendez-vous à votre convenance.

Nos solutions sont spécialement adaptées aux besoins des seniors et nous avons aidé plus de 5000 personnes comme vous à sécuriser leur avenir.

Pourriez-vous me confirmer vos disponibilités pour un entretien cette semaine ? Je peux me déplacer ou nous pouvons organiser un rendez-vous vidéo selon votre préférence.

Vous pouvez me répondre directement à cet email ou cliquer sur ce lien pour choisir un créneau : [LIEN_CALENDLY]

Cordialement,
{{collaborator_name}}
{{collaborator_phone}}', 'fb_senior_followup_1', '["first_name", "collaborator_name", "collaborator_phone"]'),

('00000000-0000-0000-0000-000000000001', 'Relance Prospect Senior FB - 2ème relance', 'Dernière chance - Votre protection senior', 
'Bonjour {{first_name}},

Je vous ai contacté récemment suite à votre intérêt pour nos solutions d''assurance senior, mais je n''ai pas encore eu de retour de votre part.

Je ne voudrais pas que vous passiez à côté de cette opportunité de sécuriser votre avenir avec des conditions préférentielles réservées aux seniors.

Cette semaine seulement, nous offrons :
✓ Évaluation gratuite de vos besoins
✓ Devis personnalisé sans engagement
✓ Conseils d''expert adaptés à votre situation

Il me suffit de 15 minutes pour vous expliquer comment nous pouvons vous aider.

Répondez simplement "OUI" à cet email et je vous rappellerai au moment qui vous convient le mieux.

Bien à vous,
{{collaborator_name}}
Conseiller Senior Spécialisé', 'fb_senior_followup_2', '["first_name", "collaborator_name"]'),

('00000000-0000-0000-0000-000000000001', 'Relance Prospect Senior FB - Dernière tentative', 'Votre dossier sera archivé demain', 
'Bonjour {{first_name}},

C''est avec regret que je vous informe que votre dossier de demande d''information sera archivé demain si je n''ai pas de retour de votre part.

Je comprends que vous êtes peut-être occupé ou que vous avez des doutes. C''est tout à fait normal.

Permettez-moi de vous rassurer : notre approche est différente. Nous prenons le temps d''écouter vos besoins réels et nous ne vous proposons que ce qui vous convient vraiment.

Si vous souhaitez garder votre dossier ouvert, répondez simplement à cet email avant demain 18h.

Sinon, je respecterai votre choix et vous ne recevrez plus de messages de ma part.

Merci pour votre attention,
{{collaborator_name}}', 'fb_senior_followup_3', '["first_name", "collaborator_name"]'),

('00000000-0000-0000-0000-000000000001', 'Bienvenue Nouveau Prospect', 'Bienvenue ! Votre conseiller dédié vous contacte', 
'Bonjour {{first_name}},

Bienvenue chez CRM Pro ! Nous sommes ravis de vous compter parmi nos prospects.

Je suis {{collaborator_name}}, votre conseiller dédié. Mon rôle est de vous accompagner dans la recherche de la solution d''assurance qui correspond parfaitement à vos besoins.

Voici ce qui va se passer maintenant :
1. Je vais étudier votre profil dans les 24h
2. Je vous préparerai une première analyse gratuite
3. Je vous contacterai pour planifier un rendez-vous

En attendant, n''hésitez pas à me faire part de vos questions ou préoccupations en répondant à cet email.

À très bientôt,
{{collaborator_name}}
Votre conseiller dédié
📞 {{collaborator_phone}}
📧 {{collaborator_email}}', 'welcome_new_prospect', '["first_name", "collaborator_name", "collaborator_phone", "collaborator_email"]');

-- Workflows automatiques
INSERT INTO workflows (name, trigger_type, trigger_config, actions, is_active, created_by) VALUES
('Relance Prospects Seniors Facebook', 'contact_created', 
'{"conditions": [{"field": "source", "operator": "equals", "value": "Facebook"}, {"field": "profession", "operator": "contains", "value": "Retraité"}]}',
'[
  {"type": "wait", "duration": "1_day"},
  {"type": "send_email", "template_id": "fb_senior_followup_1", "delay": "0"},
  {"type": "wait", "duration": "3_days"},
  {"type": "send_email", "template_id": "fb_senior_followup_2", "delay": "0"},
  {"type": "wait", "duration": "5_days"},
  {"type": "send_email", "template_id": "fb_senior_followup_3", "delay": "0"},
  {"type": "create_task", "title": "Appel final prospect senior", "delay": "1_day"}
]', true, '00000000-0000-0000-0000-000000000001'),

('Bienvenue Nouveaux Prospects', 'contact_created',
'{"conditions": [{"field": "status", "operator": "equals", "value": "prospect"}]}',
'[
  {"type": "send_email", "template_id": "welcome_new_prospect", "delay": "1_hour"},
  {"type": "create_task", "title": "Premier contact avec {{first_name}} {{last_name}}", "delay": "1_day"},
  {"type": "create_notification", "title": "Nouveau prospect à contacter", "message": "{{first_name}} {{last_name}} attend votre appel", "delay": "2_hours"}
]', true, '00000000-0000-0000-0000-000000000001'),

('Suivi Prospects Inactifs', 'scheduled',
'{"schedule": "weekly", "day": "monday", "time": "09:00"}',
'[
  {"type": "find_contacts", "conditions": [{"field": "status", "operator": "equals", "value": "prospect"}, {"field": "last_interaction", "operator": "older_than", "value": "7_days"}]},
  {"type": "send_email", "template_id": "fb_senior_followup_1", "delay": "0"},
  {"type": "create_task", "title": "Relancer prospects inactifs", "delay": "0"}
]', true, '00000000-0000-0000-0000-000000000001');
