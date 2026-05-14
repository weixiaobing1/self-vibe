package com.mindflow.vo;

import java.time.LocalDateTime;

/**
 * 复习计划展示
 */
public class ReviewPlanVO {

    private Long planId;
    private Long noteId;
    private String noteSummary;
    private String category;
    private String tags;
    private LocalDateTime nextReviewTime;
    private Integer reviewCount;
    private Integer memoryScore;
    private LocalDateTime lastReviewTime;

    public Long getPlanId() { return planId; }
    public void setPlanId(Long planId) { this.planId = planId; }
    public Long getNoteId() { return noteId; }
    public void setNoteId(Long noteId) { this.noteId = noteId; }
    public String getNoteSummary() { return noteSummary; }
    public void setNoteSummary(String noteSummary) { this.noteSummary = noteSummary; }
    public String getCategory() { return category; }
    public void setCategory(String category) { this.category = category; }
    public String getTags() { return tags; }
    public void setTags(String tags) { this.tags = tags; }
    public LocalDateTime getNextReviewTime() { return nextReviewTime; }
    public void setNextReviewTime(LocalDateTime nextReviewTime) { this.nextReviewTime = nextReviewTime; }
    public Integer getReviewCount() { return reviewCount; }
    public void setReviewCount(Integer reviewCount) { this.reviewCount = reviewCount; }
    public Integer getMemoryScore() { return memoryScore; }
    public void setMemoryScore(Integer memoryScore) { this.memoryScore = memoryScore; }
    public LocalDateTime getLastReviewTime() { return lastReviewTime; }
    public void setLastReviewTime(LocalDateTime lastReviewTime) { this.lastReviewTime = lastReviewTime; }
}