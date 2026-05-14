class Achievement {
  final String id;
  final String icon;
  final String title;
  final String description;
  final bool Function(SummaryData data) condition;

  const Achievement({
    required this.id,
    required this.icon,
    required this.title,
    required this.description,
    required this.condition,
  });
}

class SummaryData {
  final int totalNotes;
  final int totalReviews;
  final int totalInterviews;
  final int totalStudySeconds;
  final int currentStreak;
  final int longestStreak;

  const SummaryData({
    this.totalNotes = 0,
    this.totalReviews = 0,
    this.totalInterviews = 0,
    this.totalStudySeconds = 0,
    this.currentStreak = 0,
    this.longestStreak = 0,
  });

  factory SummaryData.fromJson(Map<String, dynamic> json) {
    return SummaryData(
      totalNotes: json['totalNotes'] ?? 0,
      totalReviews: json['totalReviews'] ?? 0,
      totalInterviews: json['totalInterviews'] ?? 0,
      totalStudySeconds: json['totalStudySeconds'] ?? 0,
      currentStreak: json['currentStreak'] ?? 0,
      longestStreak: json['longestStreak'] ?? 0,
    );
  }

  int get totalStudyHours => totalStudySeconds ~/ 3600;
}

final List<Achievement> achievements = [
  Achievement(id: 'first_note', icon: '📝', title: '初次记录', description: '创建第一篇笔记', condition: (d) => d.totalNotes >= 1),
  Achievement(id: 'note_10', icon: '📒', title: '笔记达人', description: '累计创建 10 篇笔记', condition: (d) => d.totalNotes >= 10),
  Achievement(id: 'note_50', icon: '📚', title: '笔记专家', description: '累计创建 50 篇笔记', condition: (d) => d.totalNotes >= 50),
  Achievement(id: 'streak_3', icon: '🔥', title: '连续学习', description: '连续学习 3 天', condition: (d) => d.currentStreak >= 3),
  Achievement(id: 'streak_7', icon: '⭐', title: '学习达人', description: '连续学习 7 天', condition: (d) => d.currentStreak >= 7),
  Achievement(id: 'streak_30', icon: '👑', title: '学霸模式', description: '连续学习 30 天', condition: (d) => d.currentStreak >= 30),
  Achievement(id: 'review_50', icon: '🔄', title: '复习高手', description: '累计完成 50 次复习', condition: (d) => d.totalReviews >= 50),
  Achievement(id: 'interview_5', icon: '💡', title: '面试新人', description: '掌握 5 道面试题', condition: (d) => d.totalInterviews >= 5),
  Achievement(id: 'interview_20', icon: '🎯', title: '面试达人', description: '掌握 20 道面试题', condition: (d) => d.totalInterviews >= 20),
  Achievement(id: 'study_10h', icon: '⏱️', title: '专注学习', description: '累计学习 10 小时', condition: (d) => d.totalStudyHours >= 10),
  Achievement(id: 'study_50h', icon: '🚀', title: '学习狂人', description: '累计学习 50 小时', condition: (d) => d.totalStudyHours >= 50),
];