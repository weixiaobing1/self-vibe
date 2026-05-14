package com.mindflow.vo;

import java.util.List;

/**
 * 学习趋势
 */
public class TrendVO {

    private List<String> dates;
    private List<Integer> noteCounts;
    private List<Integer> reviewCounts;
    private List<Integer> interviewCounts;
    private List<Integer> studyDurations;

    public List<String> getDates() { return dates; }
    public void setDates(List<String> dates) { this.dates = dates; }
    public List<Integer> getNoteCounts() { return noteCounts; }
    public void setNoteCounts(List<Integer> noteCounts) { this.noteCounts = noteCounts; }
    public List<Integer> getReviewCounts() { return reviewCounts; }
    public void setReviewCounts(List<Integer> reviewCounts) { this.reviewCounts = reviewCounts; }
    public List<Integer> getInterviewCounts() { return interviewCounts; }
    public void setInterviewCounts(List<Integer> interviewCounts) { this.interviewCounts = interviewCounts; }
    public List<Integer> getStudyDurations() { return studyDurations; }
    public void setStudyDurations(List<Integer> studyDurations) { this.studyDurations = studyDurations; }
}