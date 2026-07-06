import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            const SizedBox(height: 24),
            CircleAvatar(
              radius: 50,
              backgroundColor: const Color(0xFFE50914).withOpacity(0.2),
              child: const Icon(
                Icons.movie_filter_rounded,
                size: 50,
                color: Color(0xFFE50914),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'UG MOVIE',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Stream movies from Telegram',
              style: TextStyle(color: Colors.grey, fontSize: 14),
            ),
            const SizedBox(height: 40),
            const Divider(color: Color(0xFF2C2F48)),
            const SizedBox(height: 16),
            _buildMenuRow(
              icon: Icons.info_outline,
              title: 'App Version',
              subtitle: '1.0.0',
            ),
            const SizedBox(height: 16),
            _buildMenuRow(
              icon: Icons.movie_filter_rounded,
              title: 'Powered By',
              subtitle: 'Telegram + Supabase',
            ),
            const Spacer(),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuRow({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Row(
      children: [
        Icon(icon, color: Colors.grey, size: 24),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 2),
            Text(subtitle, style: const TextStyle(color: Colors.grey, fontSize: 13)),
          ],
        ),
      ],
    );
  }
}
