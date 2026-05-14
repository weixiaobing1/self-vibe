package com.mindflow.vo;

import java.time.LocalDateTime;
import java.util.List;

/**
 * 笔记详情
 */
public class NoteDetailVO {

    private Long id;
    private Long userId;
    private String content;
    private String contentType;
    private String fileUrl;
    private String summary;
    private String category;
    private String tags;
    private String difficulty;
    private String aiResult;
    private Integer isReviewed;
    private LocalDateTime createTime;
    private LocalDateTime updateTime;
    private List<InterviewQuestionVO> interviewQuestions;

    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }
    public Long getUserId() { return userId; }
    public void setUserId(Long userId) { this.userId = userId; }
    public String getContent() { return content; }
    public void setContent(String content) { this.content = content; }
    public String getContentType() { return contentType; }
    public void setContentType(String contentType) { this.contentType = contentType; }
    public String getFileUrl() { return fileUrl; }
    public void setFileUrl(String fileUrl) { this.fileUrl = fileUrl; }
    public String getSummary() { return summary; }
    public void setSummary(String summary) { this.summary = summary; }
    public String getCategory() { return category; }
    public void setCategory(String category) { this.category = category; }
    public String getTags() { return tags; }
    public void setTags(String tags) { this.tags = tags; }
    public String getDifficulty() { return difficulty; }
    public void setDifficulty(String difficulty) { this.difficulty = difficulty; }
    public String getAiResult() { return aiResult; }
    public void setAiResult(String aiResult) { this.aiResult = aiResult; }
    public Integer getIsReviewed() { return isReviewed; }
    public void setIsReviewed(Integer isReviewed) { this.isReviewed = isReviewed; }
    public LocalDateTime getCreateTime() { return createTime; }
    public void setCreateTime(LocalDateTime createTime) { this.createTime = createTime; }
    public LocalDateTime getUpdateTime() { return updateTime; }
    public void setUpdateTime(LocalDateTime updateTime) { this.updateTime = updateTime; }
    public List<InterviewQuestionVO> getInterviewQuestions() { return interviewQuestions; }
    public void setInterviewQuestions(List<InterviewQuestionVO> interviewQuestions) { this.interviewQuestions = interviewQuestions; }
}