import 'package:flutter/material.dart';

import '../../models/activity.dart';
import '../../services/activity_service.dart';
import '../../services/app_session.dart';
import '../../utils/date_utils.dart';
import 'create_activity_screen.dart';

class ActivitiesScreen extends StatefulWidget {
  const ActivitiesScreen({super.key});

  @override
  State<ActivitiesScreen> createState() => _ActivitiesScreenState();
}

class _ActivitiesScreenState extends State<ActivitiesScreen> {
  final _service = ActivityService();
  late Future<List<Activity>> _future;

  @override
  void initState() {
    super.initState();
    _reload();
  }

  void _reload() {
    final profile = AppSession.profile!;
    _future = _service.fetchActivities(
      profile.residenceId!,
      currentUserId: profile.id,
    );
  }

  Future<void> _toggleJoin(Activity activity) async {
    final profile = AppSession.profile!;
    try {
      if (activity.isJoined) {
        await _service.leave(activityId: activity.id, userId: profile.id);
      } else {
        await _service.join(activityId: activity.id, userId: profile.id);
      }
      setState(_reload);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Action impossible : $e')),
        );
      }
    }
  }

  Future<void> _delete(Activity activity) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer cette activité ?'),
        content: Text(
          'Les participants inscrits à "${activity.title}" ne verront plus '
          "cette activité. Cette action est irréversible.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Annuler'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    try {
      await _service.deleteActivity(activity.id);
      setState(_reload);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Erreur : $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final myId = AppSession.profile!.id;
    return Scaffold(
      appBar: AppBar(title: const Text('Activités')),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final created = await Navigator.of(context).push<bool>(
            MaterialPageRoute(builder: (_) => const CreateActivityScreen()),
          );
          if (created == true) setState(_reload);
        },
        child: const Icon(Icons.add),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          setState(_reload);
          await _future;
        },
        child: FutureBuilder<List<Activity>>(
          future: _future,
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }
            final activities = snapshot.data!;
            if (activities.isEmpty) {
              return ListView(
                children: const [
                  Padding(
                    padding: EdgeInsets.all(32),
                    child: Text(
                      "Aucune activité pour l'instant. Soyez le premier à "
                      "en proposer une !",
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              );
            }
            return ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: activities.length,
              itemBuilder: (context, i) {
                final a = activities[i];
                final isMine = a.isOwnedBy(myId);
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Text(
                                '${kSportLabels[a.sportType] ?? a.sportType} — '
                                '${a.title}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                            if (isMine)
                              IconButton(
                                icon: const Icon(Icons.delete_outline),
                                tooltip: 'Supprimer',
                                onPressed: () => _delete(a),
                              ),
                          ],
                        ),
                        Text(formatDateTime(a.startsAt)),
                        if (a.location != null) Text('📍 ${a.location}'),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '👥 ${a.participantsCount}/${a.maxParticipants} '
                              'participants',
                            ),
                            FilledButton(
                              onPressed: (!a.isJoined && a.isFull)
                                  ? null
                                  : () => _toggleJoin(a),
                              child: Text(
                                a.isJoined
                                    ? 'Se désinscrire'
                                    : (a.isFull ? 'Complet' : 'Je participe'),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
