package com.mindflow.dto;

/**
 * 完成复习请求
 */
public class CompleteReviewReq {

    private Long planId;
    private Integer score;

    public Long getPlanId() { return planId; }
    public void setPlanId(Long planId) { this.planId = planId; }
    public Integer getScore() { return score; }
    public void setScore(Integer score) { this.score = score; }
}