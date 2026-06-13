import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../providers/auth_provider.dart';
import '../../services/firestore_service.dart';
import '../../models/level_model.dart';
import '../../utils/constants.dart';
import 'level_detail.dart';
import 'subscription_screen.dart';
import '../settings/settings_screen.dart';

class StudentDashboard extends StatelessWidget {
  const StudentDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final firestore = FirestoreService();
    final user = auth.user;
    final hasSubscription = auth.hasActiveSubscription;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            title: Text('Hello, ${user?.name ?? 'Student'}'),
            actions: [
              IconButton(
                icon: const Icon(Icons.settings),
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const SettingsScreen()),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.logout),
                onPressed: () => auth.logout(),
              ),
            ],
          ),
          // Announcements Banner
          SliverToBoxAdapter(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('announcements')
                  .orderBy('createdAt', descending: true)
                  .limit(1)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const SizedBox.shrink();
                }
                final announcement = snapshot.data!.docs.first;
                final message = announcement['message'] as String;
                final createdAt = (announcement['createdAt'] as Timestamp).toDate();
                
                return Container(
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.orange.withOpacity(0.5)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.announcement, color: Colors.orange),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              message,
                              style: const TextStyle(color: Colors.white),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Posted: ${createdAt.toLocal().toString().split(' ')[0]}',
                              style: const TextStyle(fontSize: 10, color: Colors.white70),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: hasSubscription ? Colors.green : Colors.red,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(hasSubscription ? Icons.check_circle : Icons.lock,
                        color: Colors.white),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            hasSubscription ? 'Access Active' : 'No Active Subscription',
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                          if (hasSubscription && user?.subscriptionExpiry != null)
                            Text(
                              'Expires: ${user!.subscriptionExpiry!.toLocal().toString().split(' ')[0]}',
                              style: const TextStyle(color: Colors.white70, fontSize: 12),
                            ),
                        ],
                      ),
                    ),
                    if (!hasSubscription)
                      ElevatedButton(
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const SubscriptionScreen()),
                        ),
                        child: const Text('Subscribe'),
                      ),
                  ],
                ),
              ),
            ),
          ),
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Text('Learning Levels', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            ),
          ),
          StreamBuilder<List<LevelModel>>(
            stream: firestore.getLevels(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return const SliverToBoxAdapter(child: Text('Error loading levels'));
              }
              if (!snapshot.hasData) {
                return const SliverToBoxAdapter(child: Center(child: CircularProgressIndicator()));
              }
              final levels = snapshot.data!;
              if (levels.isEmpty) {
                return const SliverToBoxAdapter(child: Text('No levels available'));
              }
              return SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final level = levels[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: AppColors.primary,
                          child: Text('${index + 1}'),
                        ),
                        title: Text(level.title),
                        subtitle: level.description.isNotEmpty ? Text(level.description) : null,
                        trailing: hasSubscription ? const Icon(Icons.arrow_forward) : const Icon(Icons.lock),
                        onTap: () {
                          if (!hasSubscription) {
                            Navigator.push(context, MaterialPageRoute(builder: (_) => const SubscriptionScreen()));
                          } else {
                            Navigator.push(context, MaterialPageRoute(builder: (_) => LevelDetail(level: level)));
                          }
                        },
                      ),
                    );
                  },
                  childCount: levels.length,
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}