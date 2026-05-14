package com.mindflow.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.fasterxml.jackson.datatype.jsr310.JavaTimeModule;
import com.mindflow.common.ErrorCode;
import com.mindflow.entity.InterviewQuestion;
import com.mindflow.entity.Note;
import com.mindflow.exception.BusinessException;
import com.mindflow.mapper.InterviewQuestionMapper;
import com.mindflow.mapper.NoteMapper;
import com.mindflow.service.AIService;
import com.mindflow.service.NoteService;
import com.mindflow.service.ReviewService;
import com.mindflow.service.StatisticsService;
import com.mindflow.utils.UserContext;
import com.mindflow.vo.InterviewQuestionVO;
import com.mindflow.vo.NoteDetailVO;
import com.mindflow.vo.NoteVO;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Service;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collections;
import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.stream.Collectors;

/**
 * 笔记服务实现
 */
@Service
public class NoteServiceImpl extends ServiceImpl<NoteMapper, Note> implements NoteService {

    private static final Logger log = LoggerFactory.getLogger(NoteServiceImpl.class);

    private final AIService aiService;
    private final InterviewQuestionMapper interviewQuestionMapper;
    private final ReviewService reviewService;
    private final StatisticsService statisticsService;
    private final ObjectMapper objectMapper;

    public NoteServiceImpl(AIService aiService, InterviewQuestionMapper interviewQuestionMapper,
                           ReviewService reviewService, StatisticsService statisticsService) {
        this.aiService = aiService;
        this.interviewQuestionMapper = interviewQuestionMapper;
        this.reviewService = reviewService;
        this.statisticsService = statisticsService;
        this.objectMapper = new ObjectMapper();
        this.objectMapper.registerModule(new JavaTimeModule());
    }

    @Override
    public Map<String, Object> createNote(String content, String contentType) {
        Long userId = UserContext.getUserId();

        Note note = new Note();
        note.setUserId(userId);
        note.setContent(content);
        note.setContentType(contentType != null ? contentType : "text");
        save(note);

        try {
            reviewService.createReviewPlan(note.getId());
        } catch (Exception e) {
            log.warn("Failed to create review plan for note {}", note.getId(), e);
        }

        try {
            statisticsService.incrementNoteCount();
        } catch (Exception e) {
            log.warn("Failed to increment note count for user {}", userId, e);
        }

        try {
            Map<String, Object> aiResult = aiService.summarize(content);

            note.setSummary((String) aiResult.get("summary"));
            note.setCategory((String) aiResult.get("category"));

            Object tagsObj = aiResult.get("tags");
            if (tagsObj instanceof List) {
                note.setTags(String.join(",", (List<String>) tagsObj));
            }

            note.setDifficulty((String) aiResult.get("difficulty"));
            note.setAiResult(objectMapper.writeValueAsString(aiResult));
            updateById(note);

            Map<String, Object> result = new HashMap<>();
            result.put("noteId", note.getId());
            result.put("aiResult", aiResult);
            return result;
        } catch (JsonProcessingException e) {
            log.error("Failed to serialize AI result", e);
            Map<String, Object> result = new HashMap<>();
            result.put("noteId", note.getId());
            return result;
        } catch (BusinessException e) {
            log.warn("AI summary failed for note {}, continuing without AI result", note.getId());
            Map<String, Object> result = new HashMap<>();
            result.put("noteId", note.getId());
            result.put("aiResult", Collections.emptyMap());
            return result;
        }
    }

    @Override
    public Map<String, Object> getNoteList(int pageNum, int pageSize,
                                            String category, String keyword) {
        Long userId = UserContext.getUserId();

        LambdaQueryWrapper<Note> wrapper = new LambdaQueryWrapper<Note>()
                .eq(Note::getUserId, userId);

        if (category != null && !category.isEmpty()) {
            wrapper.eq(Note::getCategory, category);
        }
        if (keyword != null && !keyword.isEmpty()) {
            wrapper.and(w -> w.like(Note::getContent, keyword).or().like(Note::getTags, keyword));
        }
        wrapper.orderByDesc(Note::getCreateTime);

        Page<Note> page = page(new Page<>(pageNum, pageSize), wrapper);

        List<NoteVO> list = page.getRecords().stream().map(note -> {
            NoteVO vo = new NoteVO();
            vo.setId(note.getId());
            vo.setUserId(note.getUserId());
            vo.setContent(truncate(note.getContent(), 200));
            vo.setContentType(note.getContentType());
            vo.setSummary(note.getSummary());
            vo.setCategory(note.getCategory());
            vo.setTags(note.getTags());
            vo.setDifficulty(note.getDifficulty());
            vo.setCreateTime(note.getCreateTime());
            vo.setUpdateTime(note.getUpdateTime());
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
    public Map<String, Object> getNoteDetail(Long noteId) {
        Long userId = UserContext.getUserId();

        Note note = getById(noteId);
        if (note == null || !note.getUserId().equals(userId)) {
            throw new BusinessException(ErrorCode.NOT_FOUND);
        }

        NoteDetailVO detailVO = new NoteDetailVO();
        detailVO.setId(note.getId());
        detailVO.setUserId(note.getUserId());
        detailVO.setContent(note.getContent());
        detailVO.setContentType(note.getContentType());
        detailVO.setFileUrl(note.getFileUrl());
        detailVO.setSummary(note.getSummary());
        detailVO.setCategory(note.getCategory());
        detailVO.setTags(note.getTags());
        detailVO.setDifficulty(note.getDifficulty());
        detailVO.setAiResult(note.getAiResult());
        detailVO.setIsReviewed(note.getIsReviewed());
        detailVO.setCreateTime(note.getCreateTime());
        detailVO.setUpdateTime(note.getUpdateTime());

        List<InterviewQuestion> questions = interviewQuestionMapper.selectList(
                new LambdaQueryWrapper<InterviewQuestion>()
                        .eq(InterviewQuestion::getNoteId, noteId));
        List<InterviewQuestionVO> questionVOs = questions.stream().map(q -> {
            InterviewQuestionVO vo = new InterviewQuestionVO();
            vo.setId(q.getId());
            vo.setQuestion(q.getQuestion());
            vo.setAnswer(q.getAnswer());
            vo.setLevel(q.getLevel());
            vo.setIsMastered(q.getIsMastered());
            vo.setCreateTime(q.getCreateTime());
            return vo;
        }).collect(Collectors.toList());
        detailVO.setInterviewQuestions(questionVOs);

        Map<String, Object> result = new HashMap<>();
        result.put("noteInfo", detailVO);
        result.put("interviewQuestions", questionVOs);
        return result;
    }

    @Override
    public void deleteNote(Long noteId) {
        Long userId = UserContext.getUserId();

        Note note = getById(noteId);
        if (note == null || !note.getUserId().equals(userId)) {
            throw new BusinessException(ErrorCode.NOT_FOUND);
        }
        removeById(noteId);
    }

    @Override
    public List<InterviewQuestionVO> generateInterviewQuestions(Long noteId) {
        Long userId = UserContext.getUserId();

        Note note = getById(noteId);
        if (note == null || !note.getUserId().equals(userId)) {
            throw new BusinessException(ErrorCode.NOT_FOUND);
        }

        String knowledge = note.getSummary() != null
                ? note.getSummary() + " 标签：" + (note.getTags() != null ? note.getTags() : "")
                : note.getContent();
        String difficulty = note.getDifficulty() != null ? note.getDifficulty() : "初级";

        Map<String, Object> aiResult = aiService.generateInterview(knowledge, difficulty);

        List<Map<String, Object>> questionList = (List<Map<String, Object>>) aiResult.get("questions");
        if (questionList == null || questionList.isEmpty()) {
            return Collections.emptyList();
        }

        List<InterviewQuestionVO> result = new ArrayList<>();
        for (Map<String, Object> q : questionList) {
            InterviewQuestion entity = new InterviewQuestion();
            entity.setNoteId(noteId);
            entity.setUserId(userId);
            entity.setQuestion((String) q.get("question"));
            entity.setAnswer((String) q.get("answer"));
            entity.setLevel((String) q.get("level"));
            interviewQuestionMapper.insert(entity);

            InterviewQuestionVO vo = new InterviewQuestionVO();
            vo.setId(entity.getId());
            vo.setQuestion(entity.getQuestion());
            vo.setAnswer(entity.getAnswer());
            vo.setLevel(entity.getLevel());
            vo.setIsMastered(0);
            vo.setCreateTime(entity.getCreateTime());
            result.add(vo);
        }

        try {
            statisticsService.incrementInterviewCount();
        } catch (Exception e) {
            log.warn("Failed to increment interview count for user {}", userId, e);
        }

        return result;
    }

    private String truncate(String text, int maxLen) {
        if (text == null) return null;
        return text.length() > maxLen ? text.substring(0, maxLen) + "..." : text;
    }

    @Override
    public List<String> getCategories() {
        Long userId = UserContext.getUserId();
        LambdaQueryWrapper<Note> wrapper = new LambdaQueryWrapper<Note>()
                .eq(Note::getUserId, userId)
                .isNotNull(Note::getCategory)
                .ne(Note::getCategory, "")
                .select(Note::getCategory)
                .groupBy(Note::getCategory);
        return list(wrapper).stream()
                .map(Note::getCategory)
                .distinct()
                .collect(Collectors.toList());
    }

    @Override
    public List<String> getTags() {
        Long userId = UserContext.getUserId();
        LambdaQueryWrapper<Note> wrapper = new LambdaQueryWrapper<Note>()
                .eq(Note::getUserId, userId)
                .isNotNull(Note::getTags)
                .ne(Note::getTags, "");
        List<Note> notes = list(wrapper);
        Set<String> tagSet = new HashSet<>();
        for (Note note : notes) {
            String tags = note.getTags();
            if (tags != null && !tags.isEmpty()) {
                Arrays.stream(tags.split(","))
                        .map(String::trim)
                        .filter(t -> !t.isEmpty())
                        .forEach(tagSet::add);
            }
        }
        List<String> sorted = new ArrayList<>(tagSet);
        Collections.sort(sorted);
        return sorted;
    }
}