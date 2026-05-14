package com.mindflow.vo;

import java.util.List;

/**
 * 周统计
 */
public class WeeklyStatsVO {

    private String weekStart;
    private String weekEnd;
    private Integer totalNotes;
    private Integer totalReviews;
    private Integer totalInterviews;
    private Integer totalStudyDuration;
    private List<DailyStatsVO> dailyStats;

    public String getWeekStart() { return weekStart; }
    public void setWeekStart(String weekStart) { this.weekStart = weekStart; }
    public String getWeekEnd() { return weekEnd; }
    public void setWeekEnd(String weekEnd) { this.weekEnd = weekEnd; }
    public Integer getTotalNotes() { return totalNotes; }
    public void setTotalNotes(Integer totalNotes) { this.totalNotes = totalNotes; }
    public Integer getTotalReviews() { return totalReviews; }
    public void setTotalReviews(Integer totalReviews) { this.totalReviews = totalReviews; }
    public Integer getTotalInterviews() { return totalInterviews; }
    public void setTotalInterviews(Integer totalInterviews) { this.totalInterviews = totalInterviews; }
    public Integer getTotalStudyDuration() { return totalStudyDuration; }
    public void setTotalStudyDuration(Integer totalStudyDuration) { this.totalStudyDuration = totalStudyDuration; }
    public List<DailyStatsVO> getDailyStats() { return dailyStats; }
    public void setDailyStats(List<DailyStatsVO> dailyStats) { this.dailyStats = dailyStats; }
}