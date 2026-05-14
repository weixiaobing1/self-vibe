class DailyStats {
  final String date;
  final int studyDuration;
  final int noteCount;
  final int reviewCount;
  final int interviewCount;
  final int streak;

  DailyStats({
    required this.date,
    this.studyDuration = 0,
    this.noteCount = 0,
    this.reviewCount = 0,
    this.interviewCount = 0,
    this.streak = 0,
  });

  factory DailyStats.fromJson(Map<String, dynamic> json) {
    return DailyStats(
      date: json['date'] ?? '',
      studyDuration: json['studyDuration'] ?? 0,
      noteCount: json['noteCount'] ?? 0,
      reviewCount: json['reviewCount'] ?? 0,
      interviewCount: json['interviewCount'] ?? 0,
      streak: json['streak'] ?? 0,
    );
  }
}

class WeeklyStats {
  final String weekStart;
  final String weekEnd;
  final int totalNotes;
  final int totalReviews;
  final int totalInterviews;
  final int totalStudyDuration;
  final List<DailyStats> dailyStats;

  WeeklyStats({
    required this.weekStart,
    required this.weekEnd,
    this.totalNotes = 0,
    this.totalReviews = 0,
    this.totalInterviews = 0,
    this.totalStudyDuration = 0,
    this.dailyStats = const [],
  });

  factory WeeklyStats.fromJson(Map<String, dynamic> json) {
    return WeeklyStats(
      weekStart: json['weekStart'] ?? '',
      weekEnd: json['weekEnd'] ?? '',
      totalNotes: json['totalNotes'] ?? 0,
      totalReviews: json['totalReviews'] ?? 0,
      totalInterviews: json['totalInterviews'] ?? 0,
      totalStudyDuration: json['totalStudyDuration'] ?? 0,
      dailyStats: (json['dailyStats'] as List<dynamic>?)
              ?.map((e) => DailyStats.fromJson(e))
              .toList() ??
          [],
    );
  }
}

class Trend {
  final List<String> dates;
  final List<int> noteCounts;
  final List<int> reviewCounts;
  final List<int> interviewCounts;
  final List<int> studyDurations;

  Trend({
    this.dates = const [],
    this.noteCounts = const [],
    this.reviewCounts = const [],
    this.interviewCounts = const [],
    this.studyDurations = const [],
  });

  factory Trend.fromJson(Map<String, dynamic> json) {
    return Trend(
      dates: List<String>.from(json['dates'] ?? []),
      noteCounts: List<int>.from(json['noteCounts'] ?? []),
      reviewCounts: List<int>.from(json['reviewCounts'] ?? []),
      interviewCounts: List<int>.from(json['interviewCounts'] ?? []),
      studyDurations: List<int>.from(json['studyDurations'] ?? []),
    );
  }
}

class CategoryRetention {
  final String category;
  final double avgScore;
  final int itemCount;
  final int weakCount;

  CategoryRetention({
    this.category = '未分类',
    this.avgScore = 0,
    this.itemCount = 0,
    this.weakCount = 0,
  });

  factory CategoryRetention.fromJson(Map<String, dynamic> json) {
    return CategoryRetention(
      category: json['category'] ?? '未分类',
      avgScore: (json['avgScore'] ?? 0).toDouble(),
      itemCount: json['itemCount'] ?? 0,
      weakCount: json['weakCount'] ?? 0,
    );
  }
}