import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../providers/auth_provider.dart';
import '../../utils/constants.dart';
import 'manage_levels.dart';
import 'manage_lessons.dart';
import 'manage_students.dart';

class TeacherDashboard extends StatefulWidget {
  const TeacherDashboard({super.key});

  @override
  State<TeacherDashboard> createState() => _TeacherDashboardState();
}

class _TeacherDashboardState extends State<TeacherDashboard> {
  int _levelCount = 0;
  int _lessonCount = 0;
  int _studentCount = 0;

  @override
  void initState() {
    super.initState();
    _loadCounts();
  }

  void _loadCounts() {
    FirebaseFirestore.instance.collection('levels').snapshots().listen((snapshot) {
      setState(() => _levelCount = snapshot.docs.length);
    });
    FirebaseFirestore.instance.collection('lessons').snapshots().listen((snapshot) {
      setState(() => _lessonCount = snapshot.docs.length);
    });
    FirebaseFirestore.instance.collection('users').where('role', isEqualTo: 'student').snapshots().listen((snapshot) {
      setState(() => _studentCount = snapshot.docs.length);
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Teacher Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => auth.logout(),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    const Text(
                      'Welcome back,',
                      style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
                    ),
                    Text(
                      auth.user?.name ?? 'Teacher',
                      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                _buildStatCard('Levels', _levelCount, Colors.blue),
                const SizedBox(width: 12),
                _buildStatCard('Lessons', _lessonCount, Colors.green),
                const SizedBox(width: 12),
                _buildStatCard('Students', _studentCount, Colors.purple),
              ],
            ),
            const SizedBox(height: 24),
            const Text(
              'Manage Content',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildMenuItem(
              context,
              icon: Icons.menu_book,
              title: 'Manage Levels',
              subtitle: 'Add or delete learning levels',
              color: Colors.blue,
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ManageLevels())),
            ),
            const SizedBox(height: 12),
            _buildMenuItem(
              context,
              icon: Icons.video_library,
              title: 'Manage Lessons',
              subtitle: 'Add videos, documents and text',
              color: Colors.green,
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ManageLessons())),
            ),
            const SizedBox(height: 12),
            _buildMenuItem(
              context,
              icon: Icons.people,
              title: 'Manage Students',
              subtitle: 'View and manage student accounts',
              color: Colors.purple,
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ManageStudents())),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, int count, Color color) {
    return Expanded(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            children: [
              Text(
                count.toString(),
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color),
              ),
              const SizedBox(height: 4),
              Text(title, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuItem(BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.2),
          child: Icon(icon, color: color),
        ),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.arrow_forward),
        onTap: onTap,
      ),
    );
  }
}