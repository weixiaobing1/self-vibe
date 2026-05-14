package com.mindflow.controller;

import com.mindflow.common.Result;
import com.mindflow.service.InterviewService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import org.springframework.web.bind.annotation.*;

import java.util.Map;

@RestController
@RequestMapping("/api/interview")
@Tag(name = "面试题练习模块")
public class InterviewController {

    private final InterviewService interviewService;

    public InterviewController(InterviewService interviewService) {
        this.interviewService = interviewService;
    }

    @GetMapping("/questions")
    @Operation(summary = "分页查询面试题列表")
    public Result<Map<String, Object>> questions(@RequestParam(defaultValue = "1") int pageNum,
                                                  @RequestParam(defaultValue = "10") int pageSize,
                                                  @RequestParam(required = false) String level,
                                                  @RequestParam(required = false) Integer isMastered) {
        return Result.success(interviewService.getQuestions(pageNum, pageSize, level, isMastered));
    }

    @PutMapping("/questions/{id}/toggle-mastered")
    @Operation(summary = "切换面试题掌握状态")
    public Result<Void> toggleMastered(@PathVariable Long id) {
        interviewService.toggleMastered(id);
        return Result.success();
    }
}