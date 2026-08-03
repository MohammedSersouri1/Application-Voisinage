import 'package:flutter/material.dart';

import '../../models/job_post.dart';
import '../../services/app_session.dart';
import '../../services/job_service.dart';
import 'create_job_post_screen.dart';

class JobsScreen extends StatefulWidget {
  const JobsScreen({super.key});

  @override
  State<JobsScreen> createState() => _JobsScreenState();
}

class _JobsScreenState extends State<JobsScreen> {
  final _service = JobService();
  late Future<List<JobPost>> _future;

  @override
  void initState() {
    super.initState();
    _reload();
  }

  void _reload() {
    _future = _service.fetchOpen(AppSession.profile!.residenceId!);
  }

  Future<void> _respond(JobPost post) async {
    try {
      await _service.respond(jobPostId: post.id, userId: AppSession.profile!.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Votre intérêt a été transmis !')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Erreur : $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Opportunités'),
          bottom: const TabBar(
            tabs: [
              Tab(text: '🔵 Je recherche'),
              Tab(text: '🟢 Je propose'),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () async {
            final created = await Navigator.of(context).push<bool>(
              MaterialPageRoute(builder: (_) => const CreateJobPostScreen()),
            );
            if (created == true) setState(_reload);
          },
          child: const Icon(Icons.add),
        ),
        body: FutureBuilder<List<JobPost>>(
          future: _future,
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }
            final posts = snapshot.data!;
            final recherche =
                posts.where((p) => p.direction == 'recherche').toList();
            final propose =
                posts.where((p) => p.direction == 'propose').toList();
            return TabBarView(
              children: [
                _JobList(posts: recherche, onRespond: _respond),
                _JobList(posts: propose, onRespond: _respond),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _JobList extends StatelessWidget {
  final List<JobPost> posts;
  final Future<void> Function(JobPost) onRespond;

  const _JobList({required this.posts, required this.onRespond});

  @override
  Widget build(BuildContext context) {
    if (posts.isEmpty) {
      return const Center(child: Text('Rien pour le moment.'));
    }
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: posts.length,
      itemBuilder: (context, i) {
        final p = posts[i];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  kJobCategories[p.category] ?? p.category,
                  style: const TextStyle(color: Colors.grey),
                ),
                Text(
                  p.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                if (p.description != null) ...[
                  const SizedBox(height: 4),
                  Text(p.description!),
                ],
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerRight,
                  child: FilledButton(
                    onPressed: () => onRespond(p),
                    child: const Text('📩 Contacter'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
