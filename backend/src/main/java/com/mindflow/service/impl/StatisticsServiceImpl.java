package com.mindflow.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.mindflow.entity.InterviewQuestion;
import com.mindflow.entity.StudyStatistics;
import com.mindflow.mapper.InterviewQuestionMapper;
import com.mindflow.mapper.ReviewPlanMapper;
import com.mindflow.mapper.StudyStatisticsMapper;
import com.mindflow.service.StatisticsService;
import com.mindflow.utils.RedisUtils;
import com.mindflow.utils.UserContext;
import com.mindflow.vo.CategoryRetentionVO;
import com.mindflow.vo.DailyStatsVO;
import com.mindflow.vo.SummaryVO;
import com.mindflow.vo.TrendVO;
import com.mindflow.vo.WeeklyStatsVO;
import org.springframework.stereotype.Service;

import java.time.DayOfWeek;
import java.time.LocalDate;
import java.time.YearMonth;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

/**
 * 学习统计服务实现
 */
@Service
public class StatisticsServiceImpl implements StatisticsService {

    private final StudyStatisticsMapper statisticsMapper;
    private final InterviewQuestionMapper interviewQuestionMapper;
    private final ReviewPlanMapper reviewPlanMapper;
    private final RedisUtils redisUtils;

    public StatisticsServiceImpl(StudyStatisticsMapper statisticsMapper,
                                  InterviewQuestionMapper interviewQuestionMapper,
                                  ReviewPlanMapper reviewPlanMapper,
                                  RedisUtils redisUtils) {
        this.statisticsMapper = statisticsMapper;
        this.interviewQuestionMapper = interviewQuestionMapper;
        this.reviewPlanMapper = reviewPlanMapper;
        this.redisUtils = redisUtils;
    }

    @Override
    public void incrementNoteCount() {
        increment(UserContext.getUserId(), "noteCount");
    }

    @Override
    public void incrementReviewCount() {
        increment(UserContext.getUserId(), "reviewCount");
    }

    @Override
    public void incrementInterviewCount() {
        increment(UserContext.getUserId(), "interviewCount");
    }

    private void increment(Long userId, String field) {
        LocalDate today = LocalDate.now();
        LambdaQueryWrapper<StudyStatistics> wrapper = new LambdaQueryWrapper<StudyStatistics>()
                .eq(StudyStatistics::getUserId, userId)
                .eq(StudyStatistics::getDate, today);

        StudyStatistics stats = statisticsMapper.selectOne(wrapper);
        if (stats == null) {
            stats = new StudyStatistics();
            stats.setUserId(userId);
            stats.setDate(today);
            stats.setStudyDuration(0);
            stats.setNoteCount(0);
            stats.setReviewCount(0);
            stats.setInterviewCount(0);
            switch (field) {
                case "noteCount": stats.setNoteCount(1); break;
                case "reviewCount": stats.setReviewCount(1); break;
                case "interviewCount": stats.setInterviewCount(1); break;
            }
            statisticsMapper.insert(stats);
        } else {
            switch (field) {
                case "noteCount": stats.setNoteCount(stats.getNoteCount() + 1); break;
                case "reviewCount": stats.setReviewCount(stats.getReviewCount() + 1); break;
                case "interviewCount": stats.setInterviewCount(stats.getInterviewCount() + 1); break;
            }
            statisticsMapper.updateById(stats);
        }
    }

    @Override
    public void addStudyDuration(int seconds) {
        Long userId = UserContext.getUserId();
        LocalDate today = LocalDate.now();
        LambdaQueryWrapper<StudyStatistics> wrapper = new LambdaQueryWrapper<StudyStatistics>()
                .eq(StudyStatistics::getUserId, userId)
                .eq(StudyStatistics::getDate, today);

        StudyStatistics stats = statisticsMapper.selectOne(wrapper);
        if (stats == null) {
            stats = new StudyStatistics();
            stats.setUserId(userId);
            stats.setDate(today);
            stats.setStudyDuration(seconds);
            stats.setNoteCount(0);
            stats.setReviewCount(0);
            stats.setInterviewCount(0);
            statisticsMapper.insert(stats);
        } else {
            int current = stats.getStudyDuration() != null ? stats.getStudyDuration() : 0;
            stats.setStudyDuration(current + seconds);
            statisticsMapper.updateById(stats);
        }
    }

    @Override
    public DailyStatsVO getDailyStats() {
        Long userId = UserContext.getUserId();

        LocalDate today = LocalDate.now();
        LambdaQueryWrapper<StudyStatistics> wrapper = new LambdaQueryWrapper<StudyStatistics>()
                .eq(StudyStatistics::getUserId, userId)
                .eq(StudyStatistics::getDate, today);

        StudyStatistics stats = statisticsMapper.selectOne(wrapper);
        DailyStatsVO vo = toDailyStatsVO(today, stats);
        vo.setStreak(computeStreak(userId));
        return vo;
    }

    @Override
    public WeeklyStatsVO getWeeklyStats() {
        Long userId = UserContext.getUserId();

        Object cached = redisUtils.getWeeklyStats(userId);
        if (cached instanceof WeeklyStatsVO) {
            return (WeeklyStatsVO) cached;
        }

        LocalDate today = LocalDate.now();
        LocalDate weekStart = today.with(DayOfWeek.MONDAY);
        LocalDate weekEnd = today.with(DayOfWeek.SUNDAY);

        LambdaQueryWrapper<StudyStatistics> wrapper = new LambdaQueryWrapper<StudyStatistics>()
                .eq(StudyStatistics::getUserId, userId)
                .ge(StudyStatistics::getDate, weekStart)
                .le(StudyStatistics::getDate, weekEnd)
                .orderByAsc(StudyStatistics::getDate);

        List<StudyStatistics> statsList = statisticsMapper.selectList(wrapper);

        WeeklyStatsVO vo = new WeeklyStatsVO();
        vo.setWeekStart(weekStart.toString());
        vo.setWeekEnd(weekEnd.toString());
        vo.setTotalNotes(0);
        vo.setTotalReviews(0);
        vo.setTotalInterviews(0);
        vo.setTotalStudyDuration(0);

        List<DailyStatsVO> dailyList = new ArrayList<>();
        for (StudyStatistics s : statsList) {
            DailyStatsVO d = toDailyStatsVO(s.getDate(), s);
            dailyList.add(d);
            vo.setTotalNotes(vo.getTotalNotes() + (s.getNoteCount() != null ? s.getNoteCount() : 0));
            vo.setTotalReviews(vo.getTotalReviews() + (s.getReviewCount() != null ? s.getReviewCount() : 0));
            vo.setTotalInterviews(vo.getTotalInterviews() + (s.getInterviewCount() != null ? s.getInterviewCount() : 0));
            vo.setTotalStudyDuration(vo.getTotalStudyDuration() + (s.getStudyDuration() != null ? s.getStudyDuration() : 0));
        }
        vo.setDailyStats(dailyList);

        redisUtils.setWeeklyStats(userId, vo);
        return vo;
    }

    @Override
    public TrendVO getTrend(int days) {
        Long userId = UserContext.getUserId();

        if (days <= 0) days = 30;

        LocalDate today = LocalDate.now();
        LocalDate startDate = today.minusDays(days - 1);

        LambdaQueryWrapper<StudyStatistics> wrapper = new LambdaQueryWrapper<StudyStatistics>()
                .eq(StudyStatistics::getUserId, userId)
                .ge(StudyStatistics::getDate, startDate)
                .le(StudyStatistics::getDate, today)
                .orderByAsc(StudyStatistics::getDate);

        List<StudyStatistics> statsList = statisticsMapper.selectList(wrapper);

        List<String> dates = new ArrayList<>();
        List<Integer> noteCounts = new ArrayList<>();
        List<Integer> reviewCounts = new ArrayList<>();
        List<Integer> interviewCounts = new ArrayList<>();
        List<Integer> studyDurations = new ArrayList<>();

        for (int i = 0; i < days; i++) {
            LocalDate date = startDate.plusDays(i);
            dates.add(date.toString());

            StudyStatistics match = statsList.stream()
                    .filter(s -> s.getDate().equals(date))
                    .findFirst().orElse(null);

            noteCounts.add(match != null && match.getNoteCount() != null ? match.getNoteCount() : 0);
            reviewCounts.add(match != null && match.getReviewCount() != null ? match.getReviewCount() : 0);
            interviewCounts.add(match != null && match.getInterviewCount() != null ? match.getInterviewCount() : 0);
            studyDurations.add(match != null && match.getStudyDuration() != null ? match.getStudyDuration() : 0);
        }

        TrendVO vo = new TrendVO();
        vo.setDates(dates);
        vo.setNoteCounts(noteCounts);
        vo.setReviewCounts(reviewCounts);
        vo.setInterviewCounts(interviewCounts);
        vo.setStudyDurations(studyDurations);
        return vo;
    }

    private DailyStatsVO toDailyStatsVO(LocalDate date, StudyStatistics stats) {
        DailyStatsVO vo = new DailyStatsVO();
        vo.setDate(date.toString());
        vo.setStudyDuration(stats != null && stats.getStudyDuration() != null ? stats.getStudyDuration() : 0);
        vo.setNoteCount(stats != null && stats.getNoteCount() != null ? stats.getNoteCount() : 0);
        vo.setReviewCount(stats != null && stats.getReviewCount() != null ? stats.getReviewCount() : 0);
        vo.setInterviewCount(stats != null && stats.getInterviewCount() != null ? stats.getInterviewCount() : 0);
        return vo;
    }

    @Override
    public List<DailyStatsVO> getHeatmap(int year, Integer month) {
        Long userId = UserContext.getUserId();

        LocalDate start, end;
        if (month != null) {
            YearMonth ym = YearMonth.of(year, month);
            start = ym.atDay(1);
            end = ym.atEndOfMonth();
        } else {
            start = LocalDate.of(year, 1, 1);
            end = LocalDate.of(year, 12, 31);
        }

        LambdaQueryWrapper<StudyStatistics> wrapper = new LambdaQueryWrapper<StudyStatistics>()
                .eq(StudyStatistics::getUserId, userId)
                .ge(StudyStatistics::getDate, start)
                .le(StudyStatistics::getDate, end)
                .orderByAsc(StudyStatistics::getDate);

        List<StudyStatistics> statsList = statisticsMapper.selectList(wrapper);
        Map<LocalDate, StudyStatistics> statsMap = new LinkedHashMap<>();
        for (StudyStatistics s : statsList) {
            statsMap.put(s.getDate(), s);
        }

        List<DailyStatsVO> result = new ArrayList<>();
        for (LocalDate d = start; !d.isAfter(end); d = d.plusDays(1)) {
            StudyStatistics s = statsMap.get(d);
            DailyStatsVO vo = toDailyStatsVO(d, s);
            result.add(vo);
        }

        int streak = computeStreak(userId);
        if (!result.isEmpty()) {
            result.get(result.size() - 1).setStreak(streak);
        }

        return result;
    }

    private int computeStreak(Long userId) {
        LocalDate today = LocalDate.now();
        LambdaQueryWrapper<StudyStatistics> wrapper = new LambdaQueryWrapper<StudyStatistics>()
                .eq(StudyStatistics::getUserId, userId)
                .orderByDesc(StudyStatistics::getDate);
        List<StudyStatistics> all = statisticsMapper.selectList(wrapper);

        int streak = 0;
        LocalDate check = today;
        while (streak < 365) {
            final LocalDate d = check;
            boolean hasActivity = all.stream().anyMatch(s -> {
                if (!s.getDate().equals(d)) return false;
                int nc = s.getNoteCount() != null ? s.getNoteCount() : 0;
                int rc = s.getReviewCount() != null ? s.getReviewCount() : 0;
                int ic = s.getInterviewCount() != null ? s.getInterviewCount() : 0;
                int sd = s.getStudyDuration() != null ? s.getStudyDuration() : 0;
                return (nc + rc + ic + sd) > 0;
            });
            if (!hasActivity) break;
            streak++;
            check = check.minusDays(1);
        }
        return streak;
    }

    @Override
    public SummaryVO getSummary() {
        Long userId = UserContext.getUserId();

        List<StudyStatistics> all = statisticsMapper.selectList(
                new LambdaQueryWrapper<StudyStatistics>()
                        .eq(StudyStatistics::getUserId, userId));

        int totalNotes = 0, totalReviews = 0, totalInterviews = 0, totalStudySeconds = 0;
        for (StudyStatistics s : all) {
            totalNotes += s.getNoteCount() != null ? s.getNoteCount() : 0;
            totalReviews += s.getReviewCount() != null ? s.getReviewCount() : 0;
            totalInterviews += s.getInterviewCount() != null ? s.getInterviewCount() : 0;
            totalStudySeconds += s.getStudyDuration() != null ? s.getStudyDuration() : 0;
        }

        int currentStreak = computeStreak(userId);

        // compute longest streak
        int longestStreak = 0;
        int runningStreak = 0;
        LocalDate prevDate = null;
        for (StudyStatistics s : all) {
            int activity = (s.getNoteCount() != null ? s.getNoteCount() : 0)
                    + (s.getReviewCount() != null ? s.getReviewCount() : 0)
                    + (s.getInterviewCount() != null ? s.getInterviewCount() : 0)
                    + (s.getStudyDuration() != null && s.getStudyDuration() > 0 ? 1 : 0);
            if (activity == 0) continue;

            if (prevDate != null && prevDate.plusDays(1).equals(s.getDate())) {
                runningStreak++;
            } else {
                runningStreak = 1;
            }
            if (runningStreak > longestStreak) longestStreak = runningStreak;
            prevDate = s.getDate();
        }

        // count mastered interview questions
        int totalMastered = interviewQuestionMapper.selectCount(
                new LambdaQueryWrapper<InterviewQuestion>()
                        .eq(InterviewQuestion::getUserId, userId)
                        .eq(InterviewQuestion::getIsMastered, 1))
                .intValue();

        SummaryVO vo = new SummaryVO();
        vo.setTotalNotes(totalNotes);
        vo.setTotalReviews(totalReviews);
        vo.setTotalInterviews(totalMastered);
        vo.setTotalStudySeconds(totalStudySeconds);
        vo.setCurrentStreak(currentStreak);
        vo.setLongestStreak(Math.max(longestStreak, currentStreak));
        return vo;
    }

    @Override
    public List<CategoryRetentionVO> getRetention() {
        Long userId = UserContext.getUserId();
        List<Map<String, Object>> rows = reviewPlanMapper.getRetentionByCategory(userId);
        List<CategoryRetentionVO> result = new ArrayList<>();
        for (Map<String, Object> row : rows) {
            String category = (String) row.get("category");
            Double avgScore = row.get("avg_score") != null
                    ? ((Number) row.get("avg_score")).doubleValue() : 0.0;
            Integer itemCount = row.get("item_count") != null
                    ? ((Number) row.get("item_count")).intValue() : 0;
            Integer weakCount = row.get("weak_count") != null
                    ? ((Number) row.get("weak_count")).intValue() : 0;
            result.add(new CategoryRetentionVO(category, avgScore, itemCount, weakCount));
        }
        return result;
    }
}