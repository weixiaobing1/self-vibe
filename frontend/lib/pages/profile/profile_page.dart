import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../providers/auth_provider.dart';
import '../../providers/statistics_provider.dart';
import 'achievements_page.dart';
import 'settings_page.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('我的')),
      body: Consumer<AuthProvider>(
        builder: (context, auth, _) {
          final user = auth.user;

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 30,
                        backgroundColor: AppTheme.accentColor,
                        child: Text(
                          (user?.nickname ?? user?.username ?? '?').substring(0, 1).toUpperCase(),
                          style: const TextStyle(fontSize: 24, color: Colors.white),
                        ),
                      ),
                      SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(user?.nickname ?? user?.username ?? '',
                                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
                            if (user?.email != null)
                              Text(user!.email!, style: TextStyle(fontSize: 13, color: AppTheme.textSecondary)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 16),
              Card(
                child: Column(
                  children: [
                    _menuItem(Icons.settings, '设置', () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsPage()));
                    }),
                    const Divider(height: 1),
                    _menuItem(Icons.emoji_events_outlined, '学习成就', () async {
                      final stats = context.read<StatisticsProvider>();
                      await stats.loadSummary();
                      if (context.mounted && stats.summary != null) {
                        Navigator.push(context, MaterialPageRoute(
                          builder: (_) => AchievementsPage(data: stats.summary!),
                        ));
                      }
                    }),
                    const Divider(height: 1),
                    _menuItem(Icons.info_outline, '关于', () {
                      showAboutDialog(
                        context: context,
                        applicationName: 'MindFlow AI',
                        applicationVersion: '1.0.0',
                        applicationLegalese: 'AI 驱动的学习助手',
                        children: [
                          const SizedBox(height: 8),
                          Text(
                            'MindFlow AI 帮助你高效学习，提供 AI 摘要、面试题生成、间隔重复复习等功能。',
                            style: TextStyle(color: AppTheme.textSecondary),
                          ),
                        ],
                      );
                    }),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => auth.logout(),
                  style: ElevatedButton.styleFrom(backgroundColor: AppTheme.error),
                  child: const Text('退出登录'),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _menuItem(IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: AppTheme.textSecondary),
      title: Text(title, style: TextStyle(color: AppTheme.textPrimary)),
      trailing: Icon(Icons.chevron_right, color: AppTheme.textSecondary),
      onTap: onTap,
    );
  }
}