package com.mindflow.service;

import com.mindflow.vo.CategoryRetentionVO;
import com.mindflow.vo.DailyStatsVO;
import com.mindflow.vo.SummaryVO;
import com.mindflow.vo.TrendVO;
import com.mindflow.vo.WeeklyStatsVO;

import java.util.List;
import java.util.Map;

/**
 * 学习统计服务接口
 */
public interface StatisticsService {

    /** 增加笔记计数 */
    void incrementNoteCount();

    /** 增加复习计数 */
    void incrementReviewCount();

    /** 增加面试题计数 */
    void incrementInterviewCount();

    /** 增加学习时长 */
    void addStudyDuration(int seconds);

    /** 今日统计 */
    DailyStatsVO getDailyStats();

    /** 本周统计 */
    WeeklyStatsVO getWeeklyStats();

    /** 学习趋势（近30天） */
    TrendVO getTrend(int days);

    /** 学习热力图 */
    List<DailyStatsVO> getHeatmap(int year, Integer month);

    /** 学习成就摘要 */
    SummaryVO getSummary();

    /** 知识保留度（按分类） */
    List<CategoryRetentionVO> getRetention();
}