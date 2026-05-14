package com.mindflow.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.mindflow.entity.ReviewPlan;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;
import org.apache.ibatis.annotations.Select;

import java.util.List;
import java.util.Map;

@Mapper
public interface ReviewPlanMapper extends BaseMapper<ReviewPlan> {

    @Select("SELECT n.category, AVG(rp.memory_score) as avg_score, COUNT(*) as item_count, " +
            "SUM(CASE WHEN rp.memory_score < 40 THEN 1 ELSE 0 END) as weak_count " +
            "FROM review_plan rp JOIN note n ON rp.note_id = n.id " +
            "WHERE rp.user_id = #{userId} AND n.category IS NOT NULL AND rp.memory_score IS NOT NULL " +
            "AND rp.deleted = 0 AND n.deleted = 0 " +
            "GROUP BY n.category")
    List<Map<String, Object>> getRetentionByCategory(@Param("userId") Long userId);
}