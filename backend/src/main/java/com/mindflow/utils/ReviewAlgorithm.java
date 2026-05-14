package com.mindflow.utils;

import java.time.LocalDateTime;
import java.util.Map;
import java.util.HashMap;

/**
 * 艾宾浩斯遗忘曲线复习算法
 */
public class ReviewAlgorithm {

    private static final Map<Integer, Integer> INTERVAL_MAP = new HashMap<>();

    static {
        INTERVAL_MAP.put(95, 1);
        INTERVAL_MAP.put(90, 7);
        INTERVAL_MAP.put(80, 30);
        INTERVAL_MAP.put(70, 60);
        INTERVAL_MAP.put(50, 90);
        INTERVAL_MAP.put(30, 7);
        INTERVAL_MAP.put(0, 1);
    }

    /**
     * 根据当前记忆分数计算下次复习时间
     */
    public static LocalDateTime generateNextReviewTime(int currentScore) {
        int clampedScore = Math.max(0, Math.min(100, currentScore));
        int interval = INTERVAL_MAP.entrySet().stream()
                .filter(entry -> clampedScore >= entry.getKey())
                .map(Map.Entry::getValue)
                .findFirst()
                .orElse(1);
        return LocalDateTime.now().plusDays(interval);
    }

    /**
     * 初始复习计划：1 天后
     */
    public static LocalDateTime initialNextReviewTime() {
        return LocalDateTime.now().plusDays(1);
    }
}