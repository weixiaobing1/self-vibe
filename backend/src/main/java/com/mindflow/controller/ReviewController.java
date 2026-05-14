package com.mindflow.controller;

import com.mindflow.common.Result;
import com.mindflow.dto.CompleteReviewReq;
import com.mindflow.service.ReviewService;
import com.mindflow.vo.ReviewPlanVO;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

/**
 * 复习计划接口
 */
@RestController
@RequestMapping("/api/review")
@Tag(name = "复习模块")
public class ReviewController {

    private final ReviewService reviewService;

    public ReviewController(ReviewService reviewService) {
        this.reviewService = reviewService;
    }

    @GetMapping("/today")
    @Operation(summary = "获取今日复习任务")
    public Result<List<ReviewPlanVO>> today() {
        return Result.success(reviewService.getTodayTasks());
    }

    @PostMapping("/complete")
    @Operation(summary = "完成复习")
    public Result<Void> complete(@RequestBody CompleteReviewReq req) {
        reviewService.completeReview(req.getPlanId(), req.getScore());
        return Result.success(null);
    }

    @GetMapping("/history")
    @Operation(summary = "复习历史")
    public Result<Map<String, Object>> history(@RequestParam(defaultValue = "1") int pageNum,
                                                @RequestParam(defaultValue = "10") int pageSize) {
        return Result.success(reviewService.getReviewHistory(pageNum, pageSize));
    }
}