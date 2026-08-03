-- ============================================================================
-- Application Voisinage — schéma de base de données (PostgreSQL / Supabase)
-- Référence : docs/cahier-des-charges-mvp.md
--
-- Convention : toutes les tables métier portent `residence_id` et sont
-- protégées par Row Level Security (RLS) pour garantir l'isolation entre
-- résidences. `auth.uid()` est l'identifiant Supabase Auth de l'utilisateur
-- connecté ; `public.users.auth_id` fait le lien vers `public.users.id`.
-- ============================================================================

create extension if not exists "pgcrypto";

-- ----------------------------------------------------------------------------
-- Résidences
-- ----------------------------------------------------------------------------
create table public.residences (
  id            uuid primary key default gen_random_uuid(),
  name          text not null,
  code          text not null unique,           -- ex: LES-OLIVIERS-482
  address       text,
  postal_code   text,
  city          text,
  manager_id    uuid,                            -- référence users.id (ajoutée après création de users)
  created_at    timestamptz not null default now()
);

-- ----------------------------------------------------------------------------
-- Utilisateurs (complément de auth.users)
-- ----------------------------------------------------------------------------
create type residence_status as enum ('pending', 'active', 'rejected');

create table public.users (
  id                 uuid primary key default gen_random_uuid(),
  auth_id            uuid not null unique references auth.users (id) on delete cascade,
  first_name         text not null,
  last_name          text not null,
  email              text not null unique,
  phone              text unique,
  avatar_url         text,
  job_title          text,
  bio                text,
  languages          text[] not null default '{}',
  sports             text[] not null default '{}',
  residence_id       uuid references public.residences (id) on delete set null,
  apartment_number   text,
  residence_status   residence_status not null default 'pending',
  terms_accepted_at  timestamptz,
  created_at         timestamptz not null default now()
);

alter table public.residences
  add constraint residences_manager_fk foreign key (manager_id) references public.users (id) on delete set null;

-- ----------------------------------------------------------------------------
-- Compétences ("Compétences de mes voisins")
-- ----------------------------------------------------------------------------
create table public.skills (
  id    uuid primary key default gen_random_uuid(),
  code  text not null unique,   -- 'informatique', 'bricolage', 'anglais', ...
  label text not null,
  icon  text
);

create table public.user_skills (
  user_id  uuid not null references public.users (id) on delete cascade,
  skill_id uuid not null references public.skills (id) on delete cascade,
  primary key (user_id, skill_id)
);

-- ----------------------------------------------------------------------------
-- Badges / réputation communautaire
-- ----------------------------------------------------------------------------
create table public.badges (
  id          uuid primary key default gen_random_uuid(),
  code        text not null unique,  -- 'voisin_actif', 'mentor', 'organisateur', ...
  label       text not null,
  icon        text,
  description text
);

create table public.user_badges (
  user_id    uuid not null references public.users (id) on delete cascade,
  badge_id   uuid not null references public.badges (id) on delete cascade,
  awarded_at timestamptz not null default now(),
  primary key (user_id, badge_id)
);

-- ----------------------------------------------------------------------------
-- Activités (sport / loisirs)
-- ----------------------------------------------------------------------------
create type activity_status as enum ('open', 'cancelled', 'past');
create type participant_status as enum ('confirmed', 'waitlist', 'cancelled');

create table public.activities (
  id                uuid primary key default gen_random_uuid(),
  residence_id      uuid not null references public.residences (id) on delete cascade,
  creator_id        uuid not null references public.users (id) on delete cascade,
  sport_type        text not null,   -- foot, padel, tennis, running, petanque, randonnee, salle_de_sport, jeux_de_societe, autre
  title             text not null,
  description       text,
  location          text,
  starts_at         timestamptz not null,
  max_participants  integer not null check (max_participants > 0),
  status            activity_status not null default 'open',
  created_at        timestamptz not null default now()
);

create table public.activity_participants (
  activity_id uuid not null references public.activities (id) on delete cascade,
  user_id     uuid not null references public.users (id) on delete cascade,
  status      participant_status not null default 'confirmed',
  joined_at   timestamptz not null default now(),
  primary key (activity_id, user_id)
);

-- ----------------------------------------------------------------------------
-- Entraide
-- ----------------------------------------------------------------------------
create type help_direction as enum ('demande', 'proposition');
create type help_status as enum ('open', 'in_progress', 'resolved');

create table public.help_requests (
  id           uuid primary key default gen_random_uuid(),
  residence_id uuid not null references public.residences (id) on delete cascade,
  creator_id   uuid not null references public.users (id) on delete cascade,
  direction    help_direction not null default 'demande',
  category     text not null,  -- service_ponctuel, bon_plan, garde, bricolage, autre
  title        text not null,
  description  text,
  needed_at    timestamptz,
  status       help_status not null default 'open',
  created_at   timestamptz not null default now()
);

create table public.help_responses (
  id              uuid primary key default gen_random_uuid(),
  help_request_id uuid not null references public.help_requests (id) on delete cascade,
  user_id         uuid not null references public.users (id) on delete cascade,
  message         text,
  created_at      timestamptz not null default now()
);

-- ----------------------------------------------------------------------------
-- Emploi / réseau professionnel
-- ----------------------------------------------------------------------------
create type job_direction as enum ('propose', 'recherche');
create type job_status as enum ('open', 'closed');

create table public.job_posts (
  id             uuid primary key default gen_random_uuid(),
  residence_id   uuid not null references public.residences (id) on delete cascade,
  creator_id     uuid not null references public.users (id) on delete cascade,
  direction      job_direction not null,
  category       text not null,  -- stage, alternance, cdi, freelance, conseil, recommandation
  title          text not null,
  description    text,
  available_from date,
  attachment_url text,
  status         job_status not null default 'open',
  created_at     timestamptz not null default now()
);

create table public.job_responses (
  id          uuid primary key default gen_random_uuid(),
  job_post_id uuid not null references public.job_posts (id) on delete cascade,
  user_id     uuid not null references public.users (id) on delete cascade,
  message     text,
  created_at  timestamptz not null default now()
);

-- ----------------------------------------------------------------------------
-- Informations de résidence (canal descendant, géré par le gestionnaire)
-- ----------------------------------------------------------------------------
create type announcement_type as enum ('urgent', 'maintenance', 'general');

create table public.announcements (
  id           uuid primary key default gen_random_uuid(),
  residence_id uuid not null references public.residences (id) on delete cascade,
  author_id    uuid not null references public.users (id) on delete cascade,
  type         announcement_type not null default 'general',
  title        text not null,
  body         text,
  starts_at    timestamptz not null default now(),
  ends_at      timestamptz,
  created_at   timestamptz not null default now()
);

create table public.announcement_reads (
  announcement_id uuid not null references public.announcements (id) on delete cascade,
  user_id          uuid not null references public.users (id) on delete cascade,
  read_at          timestamptz not null default now(),
  primary key (announcement_id, user_id)
);

-- ----------------------------------------------------------------------------
-- Événements
-- ----------------------------------------------------------------------------
create table public.events (
  id               uuid primary key default gen_random_uuid(),
  residence_id     uuid not null references public.residences (id) on delete cascade,
  creator_id       uuid not null references public.users (id) on delete cascade,
  is_official      boolean not null default false,  -- true = créé par le gestionnaire
  title            text not null,
  description      text,
  location         text,
  starts_at        timestamptz not null,
  max_participants integer,
  created_at       timestamptz not null default now()
);

create table public.event_participants (
  event_id   uuid not null references public.events (id) on delete cascade,
  user_id    uuid not null references public.users (id) on delete cascade,
  status     participant_status not null default 'confirmed',
  joined_at  timestamptz not null default now(),
  primary key (event_id, user_id)
);

-- ----------------------------------------------------------------------------
-- Messagerie privée (déclenchée depuis "Contacter")
-- ----------------------------------------------------------------------------
create table public.conversations (
  id           uuid primary key default gen_random_uuid(),
  residence_id uuid not null references public.residences (id) on delete cascade,
  user_a_id    uuid not null references public.users (id) on delete cascade,
  user_b_id    uuid not null references public.users (id) on delete cascade,
  created_at   timestamptz not null default now(),
  unique (user_a_id, user_b_id)
);

create table public.messages (
  id              uuid primary key default gen_random_uuid(),
  conversation_id uuid not null references public.conversations (id) on delete cascade,
  sender_id       uuid not null references public.users (id) on delete cascade,
  body            text not null,
  created_at      timestamptz not null default now(),
  read_at         timestamptz
);

-- ----------------------------------------------------------------------------
-- Notifications
-- ----------------------------------------------------------------------------
create table public.notifications (
  id                  uuid primary key default gen_random_uuid(),
  user_id             uuid not null references public.users (id) on delete cascade,
  type                text not null,  -- activity, help, job, announcement, event, message
  title               text not null,
  body                text,
  related_entity_type text,
  related_entity_id   uuid,
  read_at             timestamptz,
  created_at          timestamptz not null default now()
);

create table public.notification_preferences (
  user_id       uuid not null references public.users (id) on delete cascade,
  category      text not null,  -- activities, help, jobs, announcements, events
  push_enabled  boolean not null default true,
  email_enabled boolean not null default false,
  primary key (user_id, category)
);

-- ----------------------------------------------------------------------------
-- Espace gestionnaire
-- ----------------------------------------------------------------------------
create type subscription_status as enum ('trialing', 'active', 'past_due', 'canceled');

create table public.manager_accounts (
  id                  uuid primary key default gen_random_uuid(),
  residence_id        uuid not null references public.residences (id) on delete cascade,
  user_id             uuid not null references public.users (id) on delete cascade,
  plan                text not null default 'gestionnaire',
  subscription_status subscription_status not null default 'trialing',
  stripe_customer_id  text,
  started_at          timestamptz not null default now(),
  unique (residence_id, user_id)
);

create table public.documents (
  id           uuid primary key default gen_random_uuid(),
  residence_id uuid not null references public.residences (id) on delete cascade,
  uploaded_by  uuid not null references public.users (id) on delete cascade,
  title        text not null,
  file_url     text not null,
  created_at   timestamptz not null default now()
);

create table public.polls (
  id           uuid primary key default gen_random_uuid(),
  residence_id uuid not null references public.residences (id) on delete cascade,
  author_id    uuid not null references public.users (id) on delete cascade,
  question     text not null,
  created_at   timestamptz not null default now(),
  closes_at    timestamptz
);

create table public.poll_options (
  id      uuid primary key default gen_random_uuid(),
  poll_id uuid not null references public.polls (id) on delete cascade,
  label   text not null
);

create table public.poll_votes (
  poll_option_id uuid not null references public.poll_options (id) on delete cascade,
  user_id        uuid not null references public.users (id) on delete cascade,
  created_at     timestamptz not null default now(),
  primary key (poll_option_id, user_id)
);

-- ----------------------------------------------------------------------------
-- Modération
-- ----------------------------------------------------------------------------
create type report_status as enum ('open', 'resolved', 'dismissed');

create table public.reports (
  id           uuid primary key default gen_random_uuid(),
  residence_id uuid not null references public.residences (id) on delete cascade,
  reporter_id  uuid not null references public.users (id) on delete cascade,
  target_type  text not null,  -- user, activity, help_request, job_post, announcement
  target_id    uuid not null,
  reason       text not null,
  status       report_status not null default 'open',
  created_at   timestamptz not null default now()
);

-- ----------------------------------------------------------------------------
-- Vue de statistiques (écran 10 - espace gestionnaire)
-- ----------------------------------------------------------------------------
create view public.residence_stats as
select
  r.id as residence_id,
  count(distinct u.id) filter (where u.residence_status = 'active') as total_residents,
  count(distinct u.id) filter (
    where u.residence_status = 'active'
      and exists (
        select 1 from public.notifications n
        where n.user_id = u.id and n.created_at > now() - interval '1 day'
      )
  ) as active_today
from public.residences r
left join public.users u on u.residence_id = r.id
group by r.id;

-- ============================================================================
-- ROW LEVEL SECURITY
-- Principe : un utilisateur ne voit que les données de sa propre résidence.
-- Fonction utilitaire pour récupérer la résidence de l'utilisateur courant.
-- ============================================================================

create or replace function public.current_residence_id()
returns uuid
language sql
stable
as $$
  select residence_id from public.users where auth_id = auth.uid();
$$;

create or replace function public.current_user_id()
returns uuid
language sql
stable
as $$
  select id from public.users where auth_id = auth.uid();
$$;

alter table public.users enable row level security;
alter table public.activities enable row level security;
alter table public.activity_participants enable row level security;
alter table public.help_requests enable row level security;
alter table public.help_responses enable row level security;
alter table public.job_posts enable row level security;
alter table public.job_responses enable row level security;
alter table public.announcements enable row level security;
alter table public.events enable row level security;
alter table public.event_participants enable row level security;
alter table public.notifications enable row level security;
alter table public.manager_accounts enable row level security;
alter table public.reports enable row level security;

-- Utilisateurs : lecture des voisins de la même résidence, écriture de son propre profil.
create policy "users_select_same_residence" on public.users
  for select using (residence_id = public.current_residence_id());

create policy "users_update_own_profile" on public.users
  for update using (auth_id = auth.uid());

-- Activités : lecture/écriture réservées aux membres de la résidence.
create policy "activities_select_same_residence" on public.activities
  for select using (residence_id = public.current_residence_id());

create policy "activities_insert_same_residence" on public.activities
  for insert with check (residence_id = public.current_residence_id() and creator_id = public.current_user_id());

create policy "activities_update_own" on public.activities
  for update using (creator_id = public.current_user_id());

create policy "activity_participants_select" on public.activity_participants
  for select using (
    exists (select 1 from public.activities a where a.id = activity_id and a.residence_id = public.current_residence_id())
  );

create policy "activity_participants_manage_own" on public.activity_participants
  for all using (user_id = public.current_user_id())
  with check (user_id = public.current_user_id());

-- Entraide : même logique résidence + auteur.
create policy "help_requests_select_same_residence" on public.help_requests
  for select using (residence_id = public.current_residence_id());

create policy "help_requests_insert_same_residence" on public.help_requests
  for insert with check (residence_id = public.current_residence_id() and creator_id = public.current_user_id());

create policy "help_requests_update_own" on public.help_requests
  for update using (creator_id = public.current_user_id());

create policy "help_responses_select_same_residence" on public.help_responses
  for select using (
    exists (select 1 from public.help_requests h where h.id = help_request_id and h.residence_id = public.current_residence_id())
  );

create policy "help_responses_insert_own" on public.help_responses
  for insert with check (user_id = public.current_user_id());

-- Emploi
create policy "job_posts_select_same_residence" on public.job_posts
  for select using (residence_id = public.current_residence_id());

create policy "job_posts_insert_same_residence" on public.job_posts
  for insert with check (residence_id = public.current_residence_id() and creator_id = public.current_user_id());

create policy "job_posts_update_own" on public.job_posts
  for update using (creator_id = public.current_user_id());

create policy "job_responses_select_same_residence" on public.job_responses
  for select using (
    exists (select 1 from public.job_posts j where j.id = job_post_id and j.residence_id = public.current_residence_id())
  );

create policy "job_responses_insert_own" on public.job_responses
  for insert with check (user_id = public.current_user_id());

-- Annonces : lecture pour tous les résidents, écriture réservée au gestionnaire.
create policy "announcements_select_same_residence" on public.announcements
  for select using (residence_id = public.current_residence_id());

create policy "announcements_insert_manager_only" on public.announcements
  for insert with check (
    residence_id = public.current_residence_id()
    and exists (
      select 1 from public.manager_accounts m
      where m.user_id = public.current_user_id() and m.residence_id = residence_id
    )
  );

-- Événements
create policy "events_select_same_residence" on public.events
  for select using (residence_id = public.current_residence_id());

create policy "events_insert_same_residence" on public.events
  for insert with check (residence_id = public.current_residence_id() and creator_id = public.current_user_id());

create policy "event_participants_select" on public.event_participants
  for select using (
    exists (select 1 from public.events e where e.id = event_id and e.residence_id = public.current_residence_id())
  );

create policy "event_participants_manage_own" on public.event_participants
  for all using (user_id = public.current_user_id())
  with check (user_id = public.current_user_id());

-- Notifications : uniquement les siennes.
create policy "notifications_select_own" on public.notifications
  for select using (user_id = public.current_user_id());

create policy "notifications_update_own" on public.notifications
  for update using (user_id = public.current_user_id());

-- Espace gestionnaire : réservé aux comptes gestionnaire de la résidence.
create policy "manager_accounts_select_own_residence" on public.manager_accounts
  for select using (residence_id = public.current_residence_id());

-- Signalements : l'auteur peut créer, seul le gestionnaire peut lire/traiter.
create policy "reports_insert_own" on public.reports
  for insert with check (reporter_id = public.current_user_id());

create policy "reports_select_manager_only" on public.reports
  for select using (
    exists (
      select 1 from public.manager_accounts m
      where m.user_id = public.current_user_id() and m.residence_id = reports.residence_id
    )
  );

-- ============================================================================
-- Index utiles
-- ============================================================================
create index idx_users_residence on public.users (residence_id);
create index idx_activities_residence_starts on public.activities (residence_id, starts_at);
create index idx_help_requests_residence_status on public.help_requests (residence_id, status);
create index idx_job_posts_residence_status on public.job_posts (residence_id, status);
create index idx_announcements_residence on public.announcements (residence_id, starts_at);
create index idx_events_residence_starts on public.events (residence_id, starts_at);
create index idx_notifications_user_read on public.notifications (user_id, read_at);
