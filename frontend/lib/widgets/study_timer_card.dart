import 'dart:async';
import 'package:flutter/material.dart';
import '../config/theme.dart';

class StudyTimerCard extends StatefulWidget {
  final int initialSeconds;
  final int streak;
  final int dailyGoalMinutes;
  final Future<void> Function(int seconds) onReportDuration;

  const StudyTimerCard({
    super.key,
    this.initialSeconds = 0,
    this.streak = 0,
    this.dailyGoalMinutes = 120,
    required this.onReportDuration,
  });

  @override
  State<StudyTimerCard> createState() => _StudyTimerCardState();
}

class _StudyTimerCardState extends State<StudyTimerCard> {
  bool _isRunning = false;
  int _elapsed = 0;
  Timer? _timer;

  // Pomodoro mode
  bool _pomodoroMode = false;
  bool _isFocusSession = true;
  int _sessionsCompleted = 0;
  static const int _focusSeconds = 25 * 60;
  static const int _breakSeconds = 5 * 60;
  int _pomodoroRemaining = _focusSeconds;

  // Background tracking
  DateTime? _backgroundTimestamp;
  late final AppLifecycleListener _lifecycleListener;

  int get _dailyGoalSeconds => widget.dailyGoalMinutes * 60;

  int get _totalSeconds => widget.initialSeconds + _elapsed;

  String _formatDuration(int seconds) {
    final h = seconds ~/ 3600;
    final m = (seconds % 3600) ~/ 60;
    if (h > 0) return '${h}h ${m}m';
    return '${m}m';
  }

  String _formatPomodoro(int seconds) {
    final m = seconds ~/ 60;
    final s = seconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  @override
  void initState() {
    super.initState();
    _lifecycleListener = AppLifecycleListener(
      onHide: () {
        if (_isRunning) _backgroundTimestamp = DateTime.now();
      },
      onShow: () {
        if (_backgroundTimestamp != null && _isRunning) {
          final elapsed = DateTime.now().difference(_backgroundTimestamp!).inSeconds;
          setState(() {
            if (_pomodoroMode) {
              _pomodoroRemaining = (_pomodoroRemaining - elapsed).clamp(0, _focusSeconds);
            } else {
              _elapsed += elapsed;
            }
          });
          _backgroundTimestamp = null;
        }
      },
    );
  }

  void _toggleTimer() {
    if (_isRunning) {
      _timer?.cancel();
      if (!_pomodoroMode) {
        widget.onReportDuration(_elapsed);
      }
      setState(() {
        _isRunning = false;
        if (!_pomodoroMode) _elapsed = 0;
      });
    } else {
      _timer = Timer.periodic(const Duration(seconds: 1), (_) => _onTick());
      setState(() => _isRunning = true);
    }
  }

  void _onTick() {
    setState(() {
      if (_pomodoroMode) {
        _pomodoroRemaining--;
        if (_pomodoroRemaining <= 0) {
          _timer?.cancel();
          _isRunning = false;
          if (_isFocusSession) {
            _sessionsCompleted++;
            widget.onReportDuration(_focusSeconds);
            _isFocusSession = false;
            _pomodoroRemaining = _breakSeconds;
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('专注完成！休息 5 分钟吧 (已坚持 ${_sessionsCompleted} 轮)'),
                  duration: const Duration(seconds: 3),
                ),
              );
            }
          } else {
            _isFocusSession = true;
            _pomodoroRemaining = _focusSeconds;
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('休息结束，开始新的专注吧！'),
                  duration: const Duration(seconds: 3),
                ),
              );
            }
          }
        }
      } else {
        _elapsed++;
      }
    });
  }

  void _setPomodoroMode(bool enabled) {
    _timer?.cancel();
    setState(() {
      _pomodoroMode = enabled;
      _isRunning = false;
      _isFocusSession = true;
      _pomodoroRemaining = _focusSeconds;
      _elapsed = 0;
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _lifecycleListener.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final displaySeconds = _pomodoroMode ? _pomodoroRemaining : _totalSeconds;
    final goalSeconds = _pomodoroMode
        ? (_isFocusSession ? _focusSeconds : _breakSeconds)
        : _dailyGoalSeconds;
    final progress = goalSeconds > 0 ? (displaySeconds / goalSeconds).clamp(0.0, 1.0) : 0.0;
    final isFocus = !_pomodoroMode || _isFocusSession;
    final ringColor = !_isRunning
        ? AppTheme.textSecondary
        : isFocus
            ? AppTheme.warning
            : AppTheme.success;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.timer_outlined, color: AppTheme.accentColor, size: 20),
                SizedBox(width: 8),
                Text('学习计时', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
                const Spacer(),
                if (widget.streak > 0)
                  Row(
                    children: [
                      Icon(Icons.local_fire_department, color: AppTheme.warning, size: 18),
                      SizedBox(width: 4),
                      Text('${widget.streak} 天', style: TextStyle(color: AppTheme.warning, fontSize: 14, fontWeight: FontWeight.bold)),
                    ],
                  ),
              ],
            ),
            // Pomodoro toggle
            Row(
              children: [
                Text('番茄钟', style: TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
                Transform.scale(
                  scale: 0.8,
                  child: Switch(
                    value: _pomodoroMode,
                    onChanged: _setPomodoroMode,
                    activeTrackColor: AppTheme.warning,
                  ),
                ),
                if (_pomodoroMode && _sessionsCompleted > 0)
                  Text('${_sessionsCompleted}轮', style: TextStyle(fontSize: 12, color: AppTheme.warning)),
              ],
            ),
            SizedBox(height: 8),
            Row(
              children: [
                SizedBox(
                  width: 72,
                  height: 72,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        width: 72,
                        height: 72,
                        child: CircularProgressIndicator(
                          value: progress,
                          strokeWidth: 5,
                          backgroundColor: AppTheme.surfaceColor,
                          color: ringColor,
                        ),
                      ),
                      Icon(
                        _isRunning ? Icons.pause : Icons.play_arrow,
                        color: _isRunning ? ringColor : AppTheme.accentColor,
                        size: 32,
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _pomodoroMode ? _formatPomodoro(displaySeconds) : _formatDuration(displaySeconds),
                        style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
                      ),
                      SizedBox(height: 4),
                      Text(
                        _pomodoroMode
                            ? (_isFocusSession ? '专注中' : '休息中')
                            : '今日目标: ${_formatDuration(_dailyGoalSeconds)}',
                        style: TextStyle(
                          fontSize: 12,
                          color: _pomodoroMode && _isRunning
                              ? (_isFocusSession ? AppTheme.warning : AppTheme.success)
                              : AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _toggleTimer,
                icon: Icon(_isRunning ? Icons.pause : Icons.play_arrow, size: 18),
                label: Text(_isRunning ? '暂停' : '开始学习'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _isRunning ? AppTheme.warning : AppTheme.accentColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}