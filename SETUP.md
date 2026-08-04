# Faire tourner le MVP (Flutter + Supabase)

Ce guide explique comment lancer l'application mobile pour tester le
concept avec vos 30-50 premiers voisins. Le code de l'app est dans
`mobile/`, le cahier des charges dans `cahierdeschargesmvp.md`, le schéma
de base de données dans `databaseschema.sql`.

## 1. Créer le backend (Supabase) — 15 min

1. Créez un compte gratuit sur [supabase.com](https://supabase.com) et un
   nouveau projet.
2. Dans l'éditeur SQL du projet (**SQL Editor**), collez tout le contenu de
   `databaseschema.sql` à la racine du dépôt et exécutez-le. Ça crée toutes
   les tables, types et règles de sécurité (RLS).
3. **Important pour le pilote** : allez dans **Authentication → Providers →
   Email**, et désactivez **"Confirm email"**. Sans ça, un utilisateur qui
   s'inscrit n'a pas de session active tant qu'il n'a pas cliqué un lien de
   confirmation, et la création de son profil échouera. Pour un test entre
   30-50 voisins que vous connaissez, ce n'est pas nécessaire.
4. Créez votre première résidence : dans **Table Editor → residences**,
   ajoutez une ligne avec un `name` (ex. "Les Oliviers") et un `code` unique
   (ex. `LES-OLIVIERS-482`). C'est ce code que vos voisins utiliseront pour
   rejoindre l'app (écran 2).
5. Récupérez vos clés d'API : **Project Settings → API** → copiez
   **Project URL** et **anon public key**.

## 2. Préparer le projet Flutter — 10 min

Prérequis : [Flutter SDK](https://docs.flutter.dev/get-started/install)
installé (`flutter doctor` sans erreur bloquante). Pour tester directement
dans Chrome sur votre PC (le plus simple pour un premier aperçu, voir §3),
Android Studio n'est pas nécessaire — seul le SDK Flutter + Chrome suffisent.

```bash
cd mobile

# Génère les dossiers android/ ios/ web/ (absents du dépôt) sans toucher au
# code déjà présent dans lib/ :
flutter create --org com.voisinage --project-name voisinage_app .

flutter pub get
```

## 3. Lancer l'app

**Option rapide (sur votre PC, dans Chrome, sans téléphone)** :
```bash
flutter run -d chrome \
  --dart-define=SUPABASE_URL=https://xxxx.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=votre_anon_key
```

**Sur un téléphone Android** (USB + mode développeur activé) ou un
simulateur/émulateur :
```bash
flutter run \
  --dart-define=SUPABASE_URL=https://xxxx.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=votre_anon_key
```

Testez le parcours complet : inscription → code résidence
(`LES-OLIVIERS-482`) → accueil → créer une activité → répondre à une
entraide → publier une opportunité → publier une information → envoyer un
message à un voisin.

Astuce : pour éviter de retaper les `--dart-define` à chaque fois, créez un
fichier `mobile/.vscode/launch.json` (VS Code) ou une configuration
"Additional arguments" dans Android Studio avec ces mêmes valeurs.

## 4. Distribuer aux 30-50 testeurs

- **Android (le plus simple pour démarrer)** :
  `flutter build apk --release --dart-define=SUPABASE_URL=... --dart-define=SUPABASE_ANON_KEY=...`
  puis partagez le fichier `.apk` généré (WhatsApp, Drive...). Les
  destinataires devront autoriser "sources inconnues" pour l'installer.
- **iOS** : nécessite un Mac (Xcode ne tourne que sur macOS) et, pour toute
  distribution au-delà de votre propre appareil, un compte Apple Developer
  (99$/an) + TestFlight. À envisager une fois le concept validé côté
  Android.

## 5. Ce qui est couvert dans ce MVP (et ce qui ne l'est pas encore)

Implémenté : inscription/connexion, rejoindre une résidence par code,
accueil (compteurs), liste des voisins (recherche par nom/métier/sport),
**messagerie privée entre voisins**, activités (créer/rejoindre/quitter/
**supprimer sa propre activité**, avec champs date et heure séparés),
entraide (créer/répondre/résoudre), emploi (créer/répondre, onglets
propose/recherche), **informations de résidence ouvertes à tous les
résidents** (pas seulement le gestionnaire).

Pas encore dans cette première version (prochaines itérations, voir le
cahier des charges) :
- Notifications push (Firebase Cloud Messaging) — la messagerie et les
  infos fonctionnent, mais sans alerte push quand l'app est fermée.
- Espace gestionnaire dédié (écran 10) — pour distinguer un compte
  "gestionnaire officiel", ajoutez temporairement une ligne dans
  `manager_accounts` via Supabase Table Editor pour un des résidents.
- Badges de réputation.
- Messagerie en temps réel (l'écran de chat se rafraîchit à l'envoi et par
  tirer-pour-rafraîchir, pas via Supabase Realtime pour l'instant).

## Note de sécurité

Chaque table est protégée par des règles Row Level Security scoping les
données à la résidence de l'utilisateur connecté — un résident d'une
résidence ne peut jamais voir les données d'une autre résidence, y compris
les conversations privées, même en manipulant l'app.
