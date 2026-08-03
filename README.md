# Application-Voisinage

Le réseau privé de votre résidence — une application mobile (iOS/Android) qui
connecte les habitants d'un même immeuble : rencontre des voisins, activités
sportives et loisirs, entraide, réseau professionnel, informations
officielles de la résidence, événements.

## Documentation

- [Cahier des charges du MVP](docs/cahier-des-charges-mvp.md) — spécification
  écran par écran (10 écrans) : objectifs, boutons/actions, données stockées,
  règles métier, parcours utilisateur, monétisation, sécurité et roadmap de
  lancement.
- [Schéma de base de données](docs/database-schema.sql) — modèle de données
  PostgreSQL complet (Supabase), avec policies Row Level Security par
  résidence.

## Stack technique envisagée

- **Application** : Flutter (ou React Native)
- **Backend** : Supabase (Auth, Postgres, Realtime, Storage, Edge Functions)
- **Notifications push** : Firebase Cloud Messaging
- **Paiement** (offre gestionnaire) : Stripe
