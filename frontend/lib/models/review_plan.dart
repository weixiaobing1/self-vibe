class ReviewPlan {
  final int planId;
  final int noteId;
  final String? noteSummary;
  final String? category;
  final String? tags;
  final String? nextReviewTime;
  final int? reviewCount;
  final int? memoryScore;
  final String? lastReviewTime;

  ReviewPlan({
    required this.planId,
    required this.noteId,
    this.noteSummary,
    this.category,
    this.tags,
    this.nextReviewTime,
    this.reviewCount,
    this.memoryScore,
    this.lastReviewTime,
  });

  factory ReviewPlan.fromJson(Map<String, dynamic> json) {
    return ReviewPlan(
      planId: json['planId'] ?? 0,
      noteId: json['noteId'] ?? 0,
      noteSummary: json['noteSummary'],
      category: json['category'],
      tags: json['tags'],
      nextReviewTime: json['nextReviewTime'],
      reviewCount: json['reviewCount'],
      memoryScore: json['memoryScore'],
      lastReviewTime: json['lastReviewTime'],
    );
  }
}