package com.mindflow.vo;

/**
 * 每日统计
 */
public class DailyStatsVO {

    private String date;
    private Integer studyDuration;
    private Integer noteCount;
    private Integer reviewCount;
    private Integer interviewCount;
    private Integer streak;

    public String getDate() { return date; }
    public void setDate(String date) { this.date = date; }
    public Integer getStudyDuration() { return studyDuration; }
    public void setStudyDuration(Integer studyDuration) { this.studyDuration = studyDuration; }
    public Integer getNoteCount() { return noteCount; }
    public void setNoteCount(Integer noteCount) { this.noteCount = noteCount; }
    public Integer getReviewCount() { return reviewCount; }
    public void setReviewCount(Integer reviewCount) { this.reviewCount = reviewCount; }
    public Integer getInterviewCount() { return interviewCount; }
    public void setInterviewCount(Integer interviewCount) { this.interviewCount = interviewCount; }
    public Integer getStreak() { return streak; }
    public void setStreak(Integer streak) { this.streak = streak; }
}