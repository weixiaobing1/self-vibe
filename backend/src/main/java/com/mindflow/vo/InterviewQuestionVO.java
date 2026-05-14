package com.mindflow.vo;

import java.time.LocalDateTime;

/**
 * 面试题展示
 */
public class InterviewQuestionVO {

    private Long id;
    private String question;
    private String answer;
    private String level;
    private Integer isMastered;
    private LocalDateTime createTime;

    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }
    public String getQuestion() { return question; }
    public void setQuestion(String question) { this.question = question; }
    public String getAnswer() { return answer; }
    public void setAnswer(String answer) { this.answer = answer; }
    public String getLevel() { return level; }
    public void setLevel(String level) { this.level = level; }
    public Integer getIsMastered() { return isMastered; }
    public void setIsMastered(Integer isMastered) { this.isMastered = isMastered; }
    public LocalDateTime getCreateTime() { return createTime; }
    public void setCreateTime(LocalDateTime createTime) { this.createTime = createTime; }
}