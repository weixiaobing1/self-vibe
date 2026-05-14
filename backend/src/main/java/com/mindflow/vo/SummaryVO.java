package com.mindflow.vo;

/**
 * 学习成就摘要 VO
 */
public class SummaryVO {

    private int totalNotes;
    private int totalReviews;
    private int totalInterviews;
    private int totalStudySeconds;
    private int currentStreak;
    private int longestStreak;

    public int getTotalNotes() { return totalNotes; }
    public void setTotalNotes(int totalNotes) { this.totalNotes = totalNotes; }
    public int getTotalReviews() { return totalReviews; }
    public void setTotalReviews(int totalReviews) { this.totalReviews = totalReviews; }
    public int getTotalInterviews() { return totalInterviews; }
    public void setTotalInterviews(int totalInterviews) { this.totalInterviews = totalInterviews; }
    public int getTotalStudySeconds() { return totalStudySeconds; }
    public void setTotalStudySeconds(int totalStudySeconds) { this.totalStudySeconds = totalStudySeconds; }
    public int getCurrentStreak() { return currentStreak; }
    public void setCurrentStreak(int currentStreak) { this.currentStreak = currentStreak; }
    public int getLongestStreak() { return longestStreak; }
    public void setLongestStreak(int longestStreak) { this.longestStreak = longestStreak; }
}