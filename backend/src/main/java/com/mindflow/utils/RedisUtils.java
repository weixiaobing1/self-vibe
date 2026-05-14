package com.mindflow.utils;

import org.springframework.data.redis.core.RedisTemplate;
import org.springframework.stereotype.Component;

import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.concurrent.TimeUnit;

/**
 * Redis 工具类：Token 存储、用户信息缓存
 */
@Component
public class RedisUtils {

    private final RedisTemplate<String, Object> redisTemplate;

    public RedisUtils(RedisTemplate<String, Object> redisTemplate) {
        this.redisTemplate = redisTemplate;
    }

    // ==================== Token 相关 ====================

    /** 缓存 Access Token */
    public void setAccessToken(Long userId, String token) {
        redisTemplate.opsForValue().set("user:token:access:" + userId, token, 2, TimeUnit.HOURS);
    }

    /** 获取 Access Token */
    public String getAccessToken(Long userId) {
        Object value = redisTemplate.opsForValue().get("user:token:access:" + userId);
        return value != null ? value.toString() : null;
    }

    /** 删除 Access Token（登出） */
    public void deleteAccessToken(Long userId) {
        redisTemplate.delete("user:token:access:" + userId);
    }

    /** 缓存 Refresh Token */
    public void setRefreshToken(Long userId, String token) {
        redisTemplate.opsForValue().set("user:token:refresh:" + userId, token, 7, TimeUnit.DAYS);
    }

    /** 获取 Refresh Token */
    public String getRefreshToken(Long userId) {
        Object value = redisTemplate.opsForValue().get("user:token:refresh:" + userId);
        return value != null ? value.toString() : null;
    }

    // ==================== 用户信息缓存 ====================

    /** 缓存用户信息 */
    public void setUserInfo(Long userId, Object userInfo) {
        redisTemplate.opsForValue().set("user:info:" + userId, userInfo, 1, TimeUnit.HOURS);
    }

    /** 获取缓存的用户信息 */
    public Object getUserInfo(Long userId) {
        return redisTemplate.opsForValue().get("user:info:" + userId);
    }

    /** 删除用户信息缓存 */
    public void deleteUserInfo(Long userId) {
        redisTemplate.delete("user:info:" + userId);
    }

    /** 通用删除 */
    public void delete(String key) {
        redisTemplate.delete(key);
    }

    /** 通用缓存写入（自定义 TTL） */
    public void set(String key, Object value, long timeout, TimeUnit unit) {
        redisTemplate.opsForValue().set(key, value, timeout, unit);
    }

    /** 通用缓存读取 */
    public Object get(String key) {
        return redisTemplate.opsForValue().get(key);
    }

    // ==================== AI 对话上下文 ====================

    /** 缓存 AI 对话上下文 */
    public void setChatContext(String sessionId, List<Map<String, Object>> messages) {
        redisTemplate.opsForValue().set("ai:chat:context:" + sessionId, messages, 30, TimeUnit.MINUTES);
    }

    /** 获取 AI 对话上下文 */
    @SuppressWarnings("unchecked")
    public List<Map<String, Object>> getChatContext(String sessionId) {
        Object value = redisTemplate.opsForValue().get("ai:chat:context:" + sessionId);
        return value != null ? (List<Map<String, Object>>) value : new ArrayList<>();
    }

    // ==================== 复习任务缓存 ====================

    /** 缓存今日复习任务 */
    public void setTodayReviewTasks(Long userId, Object tasks) {
        redisTemplate.opsForValue().set("review:today:" + userId, tasks, 1, TimeUnit.HOURS);
    }

    /** 获取今日复习任务缓存 */
    public Object getTodayReviewTasks(Long userId) {
        return redisTemplate.opsForValue().get("review:today:" + userId);
    }

    /** 删除今日复习任务缓存 */
    public void deleteTodayReviewTasks(Long userId) {
        redisTemplate.delete("review:today:" + userId);
    }

    // ==================== 统计缓存 ====================

    /** 缓存周统计 */
    public void setWeeklyStats(Long userId, Object stats) {
        redisTemplate.opsForValue().set("statistics:week:" + userId, stats, 1, TimeUnit.DAYS);
    }

    /** 获取周统计缓存 */
    public Object getWeeklyStats(Long userId) {
        return redisTemplate.opsForValue().get("statistics:week:" + userId);
    }
}