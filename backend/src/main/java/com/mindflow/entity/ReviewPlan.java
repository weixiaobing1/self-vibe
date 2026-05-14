package com.mindflow.entity;

import com.baomidou.mybatisplus.annotation.*;
import java.time.LocalDateTime;

/**
 * 复习计划表
 */
@TableName("review_plan")
public class ReviewPlan {

    @TableId(type = IdType.AUTO)
    private Long id;
    private Long userId;
    private Long noteId;
    private LocalDateTime nextReviewTime;
    private Integer reviewCount;
    private Integer memoryScore;
    private LocalDateTime lastReviewTime;

    @TableField(fill = FieldFill.INSERT)
    private LocalDateTime createTime;

    @TableField(fill = FieldFill.INSERT_UPDATE)
    private LocalDateTime updateTime;

    @TableLogic
    private Integer deleted;

    // ===== getters & setters =====
    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }
    public Long getUserId() { return userId; }
    public void setUserId(Long userId) { this.userId = userId; }
    public Long getNoteId() { return noteId; }
    public void setNoteId(Long noteId) { this.noteId = noteId; }
    public LocalDateTime getNextReviewTime() { return nextReviewTime; }
    public void setNextReviewTime(LocalDateTime nextReviewTime) { this.nextReviewTime = nextReviewTime; }
    public Integer getReviewCount() { return reviewCount; }
    public void setReviewCount(Integer reviewCount) { this.reviewCount = reviewCount; }
    public Integer getMemoryScore() { return memoryScore; }
    public void setMemoryScore(Integer memoryScore) { this.memoryScore = memoryScore; }
    public LocalDateTime getLastReviewTime() { return lastReviewTime; }
    public void setLastReviewTime(LocalDateTime lastReviewTime) { this.lastReviewTime = lastReviewTime; }
    public LocalDateTime getCreateTime() { return createTime; }
    public void setCreateTime(LocalDateTime createTime) { this.createTime = createTime; }
    public LocalDateTime getUpdateTime() { return updateTime; }
    public void setUpdateTime(LocalDateTime updateTime) { this.updateTime = updateTime; }
    public Integer getDeleted() { return deleted; }
    public void setDeleted(Integer deleted) { this.deleted = deleted; }
}