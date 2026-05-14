class Note {
  final int id;
  final int userId;
  final String? content;
  final String? contentType;
  final String? summary;
  final String? category;
  final String? tags;
  final String? difficulty;
  final String? createTime;
  final String? updateTime;

  Note({
    required this.id,
    required this.userId,
    this.content,
    this.contentType,
    this.summary,
    this.category,
    this.tags,
    this.difficulty,
    this.createTime,
    this.updateTime,
  });

  factory Note.fromJson(Map<String, dynamic> json) {
    return Note(
      id: json['id'] ?? 0,
      userId: json['userId'] ?? 0,
      content: json['content'],
      contentType: json['contentType'],
      summary: json['summary'],
      category: json['category'],
      tags: json['tags'],
      difficulty: json['difficulty'],
      createTime: json['createTime'],
      updateTime: json['updateTime'],
    );
  }
}

class NoteDetail {
  final int id;
  final int userId;
  final String? content;
  final String? contentType;
  final String? summary;
  final String? category;
  final String? tags;
  final String? difficulty;
  final String? aiResult;
  final int? isReviewed;
  final String? createTime;
  final List<InterviewQuestion> interviewQuestions;

  NoteDetail({
    required this.id,
    required this.userId,
    this.content,
    this.contentType,
    this.summary,
    this.category,
    this.tags,
    this.difficulty,
    this.aiResult,
    this.isReviewed,
    this.createTime,
    this.interviewQuestions = const [],
  });

  factory NoteDetail.fromJson(Map<String, dynamic> json) {
    return NoteDetail(
      id: json['id'] ?? 0,
      userId: json['userId'] ?? 0,
      content: json['content'],
      contentType: json['contentType'],
      summary: json['summary'],
      category: json['category'],
      tags: json['tags'],
      difficulty: json['difficulty'],
      aiResult: json['aiResult'],
      isReviewed: json['isReviewed'],
      createTime: json['createTime'],
      interviewQuestions: (json['interviewQuestions'] as List<dynamic>?)
              ?.map((e) => InterviewQuestion.fromJson(e))
              .toList() ??
          [],
    );
  }
}

class InterviewQuestion {
  final int id;
  final String? question;
  final String? answer;
  final String? level;
  final int? isMastered;
  final String? createTime;

  InterviewQuestion({
    required this.id,
    this.question,
    this.answer,
    this.level,
    this.isMastered,
    this.createTime,
  });

  factory InterviewQuestion.fromJson(Map<String, dynamic> json) {
    return InterviewQuestion(
      id: json['id'] ?? 0,
      question: json['question'],
      answer: json['answer'],
      level: json['level'],
      isMastered: json['isMastered'],
      createTime: json['createTime'],
    );
  }
}