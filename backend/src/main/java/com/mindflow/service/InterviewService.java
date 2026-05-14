package com.mindflow.service;

import java.util.Map;

/**
 * 面试题练习服务接口
 */
public interface InterviewService {

    /** 分页查询面试题 */
    Map<String, Object> getQuestions(int pageNum, int pageSize, String level, Integer isMastered);

    /** 切换掌握状态 */
    void toggleMastered(Long id);
}