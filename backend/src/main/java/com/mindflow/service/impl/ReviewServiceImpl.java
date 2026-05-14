package com.mindflow.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.mindflow.common.ErrorCode;
import com.mindflow.entity.Note;
import com.mindflow.entity.ReviewPlan;
import com.mindflow.exception.BusinessException;
import com.mindflow.mapper.NoteMapper;
import com.mindflow.mapper.ReviewPlanMapper;
import com.mindflow.service.ReviewService;
import com.mindflow.service.StatisticsService;
import com.mindflow.utils.RedisUtils;
import com.mindflow.utils.ReviewAlgorithm;
import com.mindflow.utils.UserContext;
import com.mindflow.vo.ReviewPlanVO;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Service;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.LocalTime;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

/**
 * 复习计划服务实现
 */
@Service
public class ReviewServiceImpl extends ServiceImpl<ReviewPlanMapper, ReviewPlan> implements ReviewService {

    private static final Logger log = LoggerFactory.getLogger(ReviewServiceImpl.class);

    private final NoteMapper noteMapper;
    private final RedisUtils redisUtils;
    private final StatisticsService statisticsService;

    public ReviewServiceImpl(NoteMapper noteMapper, RedisUtils redisUtils, StatisticsService statisticsService) {
        this.noteMapper = noteMapper;
        this.redisUtils = redisUtils;
        this.statisticsService = statisticsService;
    }

    @Override
    public void createReviewPlan(Long noteId) {
        Long userId = UserContext.getUserId();

        ReviewPlan plan = new ReviewPlan();
        plan.setUserId(userId);
        plan.setNoteId(noteId);
        plan.setNextReviewTime(ReviewAlgorithm.initialNextReviewTime());
        plan.setReviewCount(0);
        plan.setMemoryScore(100);
        save(plan);
        log.info("Created review plan for note {} user {}", noteId, userId);
    }

    @Override
    public List<ReviewPlanVO> getTodayTasks() {
        Long userId = UserContext.getUserId();

        Object cached = redisUtils.getTodayReviewTasks(userId);
        if (cached instanceof List) {
            @SuppressWarnings("unchecked")
            List<ReviewPlanVO> cachedList = (List<ReviewPlanVO>) cached;
            return cachedList;
        }

        LocalDateTime todayStart = LocalDate.now().atStartOfDay();
        LocalDateTime todayEnd = LocalDate.now().atTime(LocalTime.MAX);

        LambdaQueryWrapper<ReviewPlan> wrapper = new LambdaQueryWrapper<ReviewPlan>()
                .eq(ReviewPlan::getUserId, userId)
                .le(ReviewPlan::getNextReviewTime, todayEnd)
                .ge(ReviewPlan::getNextReviewTime, todayStart)
                .orderByAsc(ReviewPlan::getNextReviewTime);

        List<ReviewPlan> plans = list(wrapper);
        List<ReviewPlanVO> vos = plans.stream().map(plan -> {
            ReviewPlanVO vo = new ReviewPlanVO();
            vo.setPlanId(plan.getId());
            vo.setNoteId(plan.getNoteId());
            vo.setNextReviewTime(plan.getNextReviewTime());
            vo.setReviewCount(plan.getReviewCount());
            vo.setMemoryScore(plan.getMemoryScore());
            vo.setLastReviewTime(plan.getLastReviewTime());

            Note note = noteMapper.selectById(plan.getNoteId());
            if (note != null) {
                vo.setNoteSummary(note.getSummary());
                vo.setCategory(note.getCategory());
                vo.setTags(note.getTags());
            }
            return vo;
        }).collect(Collectors.toList());

        redisUtils.setTodayReviewTasks(userId, vos);
        return vos;
    }

    @Override
    public void completeReview(Long planId, int score) {
        Long userId = UserContext.getUserId();

        ReviewPlan plan = getById(planId);
        if (plan == null || !plan.getUserId().equals(userId)) {
            throw new BusinessException(ErrorCode.NOT_FOUND);
        }

        int clampedScore = Math.max(0, Math.min(100, score));
        plan.setMemoryScore(clampedScore);
        plan.setReviewCount(plan.getReviewCount() != null ? plan.getReviewCount() + 1 : 1);
        plan.setLastReviewTime(LocalDateTime.now());
        plan.setNextReviewTime(ReviewAlgorithm.generateNextReviewTime(clampedScore));
        updateById(plan);

        redisUtils.deleteTodayReviewTasks(userId);

        statisticsService.incrementReviewCount();
        log.info("User {} completed review plan {}, score {}", userId, planId, clampedScore);
    }

    @Override
    public Map<String, Object> getReviewHistory(int pageNum, int pageSize) {
        Long userId = UserContext.getUserId();

        LambdaQueryWrapper<ReviewPlan> wrapper = new LambdaQueryWrapper<ReviewPlan>()
                .eq(ReviewPlan::getUserId, userId)
                .isNotNull(ReviewPlan::getLastReviewTime)
                .orderByDesc(ReviewPlan::getLastReviewTime);

        Page<ReviewPlan> page = page(new Page<>(pageNum, pageSize), wrapper);

        List<ReviewPlanVO> list = page.getRecords().stream().map(plan -> {
            ReviewPlanVO vo = new ReviewPlanVO();
            vo.setPlanId(plan.getId());
            vo.setNoteId(plan.getNoteId());
            vo.setNextReviewTime(plan.getNextReviewTime());
            vo.setReviewCount(plan.getReviewCount());
            vo.setMemoryScore(plan.getMemoryScore());
            vo.setLastReviewTime(plan.getLastReviewTime());

            Note note = noteMapper.selectById(plan.getNoteId());
            if (note != null) {
                vo.setNoteSummary(note.getSummary());
                vo.setCategory(note.getCategory());
                vo.setTags(note.getTags());
            }
            return vo;
        }).collect(Collectors.toList());

        Map<String, Object> result = new HashMap<>();
        result.put("list", list);
        result.put("total", page.getTotal());
        result.put("pageNum", pageNum);
        result.put("pageSize", pageSize);
        return result;
    }
}