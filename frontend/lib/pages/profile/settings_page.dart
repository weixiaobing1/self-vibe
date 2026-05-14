import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../providers/auth_provider.dart';
import '../../providers/theme_provider.dart';
import '../../services/notification_service.dart';
import '../../services/api_service.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final _oldPwdCtrl = TextEditingController();
  final _newPwdCtrl = TextEditingController();
  final _confirmPwdCtrl = TextEditingController();
  bool _showPwdForm = false;
  TimeOfDay? _reminderTime;

  @override
  void initState() {
    super.initState();
    _loadReminderTime();
  }

  Future<void> _loadReminderTime() async {
    final h = await NotificationService().getReminderHour();
    final m = await NotificationService().getReminderMinute();
    if (h != null && m != null && mounted) {
      setState(() => _reminderTime = TimeOfDay(hour: h, minute: m));
    }
  }

  @override
  void dispose() {
    _oldPwdCtrl.dispose();
    _newPwdCtrl.dispose();
    _confirmPwdCtrl.dispose();
    super.dispose();
  }

  void _changePassword() async {
    final oldPwd = _oldPwdCtrl.text.trim();
    final newPwd = _newPwdCtrl.text.trim();
    final confirmPwd = _confirmPwdCtrl.text.trim();

    if (oldPwd.isEmpty || newPwd.isEmpty || confirmPwd.isEmpty) {
      _showMsg('请填写所有密码字段');
      return;
    }
    if (newPwd.length < 6) {
      _showMsg('新密码至少 6 位');
      return;
    }
    if (newPwd != confirmPwd) {
      _showMsg('两次新密码输入不一致');
      return;
    }

    final auth = context.read<AuthProvider>();
    final success = await auth.changePassword(oldPwd, newPwd);

    if (!mounted) return;
    if (success) {
      _oldPwdCtrl.clear();
      _newPwdCtrl.clear();
      _confirmPwdCtrl.clear();
      setState(() => _showPwdForm = false);
      _showMsg('密码修改成功');
    } else {
      _showMsg(auth.error ?? '修改失败');
    }
  }

  void _showMsg(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('设置')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildThemeSection(),
          SizedBox(height: 24),
          _buildDailyGoalSection(),
          SizedBox(height: 24),
          _buildReminderSection(),
          SizedBox(height: 24),
          _buildPasswordSection(),
        ],
      ),
    );
  }

  Widget _buildThemeSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('主题背景', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
            SizedBox(height: 16),
            Consumer<ThemeProvider>(
              builder: (context, tp, _) {
                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: ThemeColor.values.map((color) {
                    final isSelected = tp.color == color;
                    return GestureDetector(
                      onTap: () => tp.setColor(color),
                      child: Column(
                        children: [
                          Container(
                            width: 56,
                            height: 56,
                            decoration: BoxDecoration(
                              color: _getPreviewColor(color),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: isSelected ? AppTheme.accentColor : Colors.transparent,
                                width: 2.5,
                              ),
                              boxShadow: isSelected
                                  ? [BoxShadow(color: AppTheme.accentColor.withValues(alpha: 0.4), blurRadius: 8)]
                                  : null,
                            ),
                            child: isSelected
                                ? const Icon(Icons.check, color: Colors.white, size: 24)
                                : null,
                          ),
                          SizedBox(height: 8),
                          Text(
                            _getLabel(color),
                            style: TextStyle(
                              fontSize: 12,
                              color: isSelected ? AppTheme.accentColor : AppTheme.textSecondary,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Color _getPreviewColor(ThemeColor color) {
    switch (color) {
      case ThemeColor.white:
        return const Color(0xFFF5F5F5);
      case ThemeColor.black:
        return const Color(0xFF1A1A2E);
      case ThemeColor.blue:
        return const Color(0xFF0A1929);
      case ThemeColor.green:
        return const Color(0xFF0D1F0D);
    }
  }

  String _getLabel(ThemeColor color) {
    switch (color) {
      case ThemeColor.white:
        return '浅色';
      case ThemeColor.black:
        return '深色';
      case ThemeColor.blue:
        return '蓝色';
      case ThemeColor.green:
        return '绿色';
    }
  }

  Widget _buildDailyGoalSection() {
    return Consumer<AuthProvider>(
      builder: (context, auth, _) {
        final current = int.tryParse(auth.user?.studyTarget ?? '') ?? 120;
        final goals = [30, 60, 90, 120, 180, 240, 480];

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('每日学习目标', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
                SizedBox(height: 16),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: goals.map((m) {
                    final isSelected = current == m;
                    final label = m >= 60 ? '${m ~/ 60}h' : '${m}m';
                    if (m == 90) return const SizedBox.shrink();
                    return ChoiceChip(
                      label: Text(label),
                      selected: isSelected,
                      onSelected: (_) => _saveGoal(auth, m),
                      selectedColor: AppTheme.accentColor.withValues(alpha: 0.3),
                      labelStyle: TextStyle(
                        color: isSelected ? AppTheme.accentColor : AppTheme.textSecondary,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _saveGoal(AuthProvider auth, int minutes) async {
    try {
      await auth.updateProfile({'studyTarget': minutes.toString()});
      if (mounted) _showMsg('每日目标已更新为 ${minutes >= 60 ? "${minutes ~/ 60} 小时" : "$minutes 分钟"}');
    } catch (e) {
      final msg = e is DioException ? ApiService.extractError(e) : '保存失败';
      if (mounted) _showMsg(msg);
    }
  }

  Widget _buildReminderSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('每日复习提醒', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
            SizedBox(height: 16),
            Row(
              children: [
                Icon(Icons.notifications_outlined, color: AppTheme.textSecondary),
                SizedBox(width: 12),
                TextButton(
                  onPressed: () async {
                    final picked = await showTimePicker(
                      context: context,
                      initialTime: _reminderTime ?? const TimeOfDay(hour: 20, minute: 0),
                    );
                    if (picked != null) {
                      await NotificationService().scheduleDailyReminder(picked.hour, picked.minute);
                      setState(() => _reminderTime = picked);
                      if (mounted) _showMsg('已设置每日 ${picked.hour}:${picked.minute.toString().padLeft(2, '0')} 提醒');
                    }
                  },
                  child: Text(
                    _reminderTime != null
                        ? '${_reminderTime!.hour.toString().padLeft(2, '0')}:${_reminderTime!.minute.toString().padLeft(2, '0')}'
                        : '设置提醒时间',
                    style: TextStyle(color: AppTheme.accentColor, fontSize: 16),
                  ),
                ),
                const Spacer(),
                if (_reminderTime != null)
                  IconButton(
                    icon: Icon(Icons.close, color: AppTheme.error),
                    onPressed: () async {
                      await NotificationService().cancelAll();
                      setState(() => _reminderTime = null);
                      if (mounted) _showMsg('已取消每日提醒');
                    },
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPasswordSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('密码修改', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
                TextButton(
                  onPressed: () => setState(() => _showPwdForm = !_showPwdForm),
                  child: Text(_showPwdForm ? '收起' : '修改', style: TextStyle(color: AppTheme.accentColor)),
                ),
              ],
            ),
            if (_showPwdForm) ...[
              SizedBox(height: 16),
              TextField(
                controller: _oldPwdCtrl,
                obscureText: true,
                decoration: InputDecoration(
                  hintText: '当前密码',
                  prefixIcon: Icon(Icons.lock_outline, color: AppTheme.textSecondary),
                ),
              ),
              SizedBox(height: 12),
              TextField(
                controller: _newPwdCtrl,
                obscureText: true,
                decoration: InputDecoration(
                  hintText: '新密码（至少 6 位）',
                  prefixIcon: Icon(Icons.lock, color: AppTheme.textSecondary),
                ),
              ),
              SizedBox(height: 12),
              TextField(
                controller: _confirmPwdCtrl,
                obscureText: true,
                decoration: InputDecoration(
                  hintText: '确认新密码',
                  prefixIcon: Icon(Icons.lock, color: AppTheme.textSecondary),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: Consumer<AuthProvider>(
                  builder: (context, auth, _) {
                    return ElevatedButton(
                      onPressed: auth.isLoading ? null : _changePassword,
                      child: auth.isLoading
                          ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                          : const Text('确认修改'),
                    );
                  },
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}