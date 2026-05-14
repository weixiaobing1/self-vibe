package com.mindflow.service;

import com.baomidou.mybatisplus.extension.service.IService;
import com.mindflow.entity.ReviewPlan;
import com.mindflow.vo.ReviewPlanVO;

import java.util.List;
import java.util.Map;

/**
 * 复习计划服务接口
 */
public interface ReviewService extends IService<ReviewPlan> {

    /** 创建初始复习计划（笔记创建时调用） */
    void createReviewPlan(Long noteId);

    /** 获取今日复习任务 */
    List<ReviewPlanVO> getTodayTasks();

    /** 完成复习 */
    void completeReview(Long planId, int score);

    /** 复习历史（分页） */
    Map<String, Object> getReviewHistory(int pageNum, int pageSize);
}