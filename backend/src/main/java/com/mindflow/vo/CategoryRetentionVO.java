package com.mindflow.vo;

/**
 * 知识保留度（按分类聚合记忆评分）
 */
public class CategoryRetentionVO {

    private String category;
    private Double avgScore;
    private Integer itemCount;
    private Integer weakCount;

    public CategoryRetentionVO() {}

    public CategoryRetentionVO(String category, Double avgScore, Integer itemCount, Integer weakCount) {
        this.category = category;
        this.avgScore = avgScore;
        this.itemCount = itemCount;
        this.weakCount = weakCount;
    }

    public String getCategory() { return category; }
    public void setCategory(String category) { this.category = category; }

    public Double getAvgScore() { return avgScore; }
    public void setAvgScore(Double avgScore) { this.avgScore = avgScore; }

    public Integer getItemCount() { return itemCount; }
    public void setItemCount(Integer itemCount) { this.itemCount = itemCount; }

    public Integer getWeakCount() { return weakCount; }
    public void setWeakCount(Integer weakCount) { this.weakCount = weakCount; }
}