package com.mindflow.controller;

import com.mindflow.common.Result;
import com.mindflow.dto.ReportDurationReq;
import com.mindflow.service.StatisticsService;
import com.mindflow.vo.CategoryRetentionVO;
import com.mindflow.vo.DailyStatsVO;
import com.mindflow.vo.SummaryVO;
import com.mindflow.vo.TrendVO;
import com.mindflow.vo.WeeklyStatsVO;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import org.springframework.web.bind.annotation.*;

import java.util.List;

/**
 * 学习统计接口
 */
@RestController
@RequestMapping("/api/statistics")
@Tag(name = "学习统计模块")
public class StatisticsController {

    private final StatisticsService statisticsService;

    public StatisticsController(StatisticsService statisticsService) {
        this.statisticsService = statisticsService;
    }

    @GetMapping("/daily")
    @Operation(summary = "今日学习统计")
    public Result<DailyStatsVO> daily() {
        return Result.success(statisticsService.getDailyStats());
    }

    @GetMapping("/weekly")
    @Operation(summary = "本周学习统计")
    public Result<WeeklyStatsVO> weekly() {
        return Result.success(statisticsService.getWeeklyStats());
    }

    @GetMapping("/trend")
    @Operation(summary = "学习趋势（近N天）")
    public Result<TrendVO> trend(@RequestParam(defaultValue = "30") int days) {
        return Result.success(statisticsService.getTrend(days));
    }

    @PostMapping("/duration")
    @Operation(summary = "上报学习时长")
    public Result<Void> reportDuration(@RequestBody ReportDurationReq req) {
        statisticsService.addStudyDuration(req.getSeconds());
        return Result.success();
    }

    @GetMapping("/heatmap")
    @Operation(summary = "学习热力图（年/月维度）")
    public Result<List<DailyStatsVO>> heatmap(@RequestParam(defaultValue = "2026") int year,
                                               @RequestParam(required = false) Integer month) {
        return Result.success(statisticsService.getHeatmap(year, month));
    }

    @GetMapping("/summary")
    @Operation(summary = "学习成就摘要")
    public Result<SummaryVO> summary() {
        return Result.success(statisticsService.getSummary());
    }

    @GetMapping("/retention")
    @Operation(summary = "知识保留度（按分类聚合记忆评分）")
    public Result<List<CategoryRetentionVO>> retention() {
        return Result.success(statisticsService.getRetention());
    }
}