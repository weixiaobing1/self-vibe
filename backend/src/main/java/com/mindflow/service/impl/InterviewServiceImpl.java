package com.mindflow.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.mindflow.common.ErrorCode;
import com.mindflow.entity.InterviewQuestion;
import com.mindflow.exception.BusinessException;
import com.mindflow.mapper.InterviewQuestionMapper;
import com.mindflow.service.InterviewService;
import com.mindflow.utils.UserContext;
import com.mindflow.vo.InterviewQuestionVO;
import org.springframework.stereotype.Service;

import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

@Service
public class InterviewServiceImpl implements InterviewService {

    private final InterviewQuestionMapper interviewQuestionMapper;

    public InterviewServiceImpl(InterviewQuestionMapper interviewQuestionMapper) {
        this.interviewQuestionMapper = interviewQuestionMapper;
    }

    @Override
    public Map<String, Object> getQuestions(int pageNum, int pageSize, String level, Integer isMastered) {
        Long userId = UserContext.getUserId();

        LambdaQueryWrapper<InterviewQuestion> wrapper = new LambdaQueryWrapper<InterviewQuestion>()
                .eq(InterviewQuestion::getUserId, userId);

        if (level != null && !level.isEmpty()) {
            wrapper.eq(InterviewQuestion::getLevel, level);
        }
        if (isMastered != null) {
            wrapper.eq(InterviewQuestion::getIsMastered, isMastered);
        }
        wrapper.orderByDesc(InterviewQuestion::getCreateTime);

        Page<InterviewQuestion> page = new Page<>(pageNum, pageSize);
        interviewQuestionMapper.selectPage(page, wrapper);

        List<InterviewQuestionVO> list = page.getRecords().stream().map(q -> {
            InterviewQuestionVO vo = new InterviewQuestionVO();
            vo.setId(q.getId());
            vo.setQuestion(q.getQuestion());
            vo.setAnswer(q.getAnswer());
            vo.setLevel(q.getLevel());
            vo.setIsMastered(q.getIsMastered());
            vo.setCreateTime(q.getCreateTime());
            return vo;
        }).collect(Collectors.toList());

        Map<String, Object> result = new HashMap<>();
        result.put("list", list);
        result.put("total", page.getTotal());
        result.put("pageNum", pageNum);
        result.put("pageSize", pageSize);
        return result;
    }

    @Override
    public void toggleMastered(Long id) {
        Long userId = UserContext.getUserId();

        InterviewQuestion question = interviewQuestionMapper.selectById(id);
        if (question == null || !question.getUserId().equals(userId)) {
            throw new BusinessException(ErrorCode.NOT_FOUND);
        }

        int current = question.getIsMastered() != null ? question.getIsMastered() : 0;
        question.setIsMastered(current == 1 ? 0 : 1);
        interviewQuestionMapper.updateById(question);
    }
}