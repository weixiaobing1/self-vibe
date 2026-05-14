package com.mindflow.service;

import com.baomidou.mybatisplus.extension.service.IService;
import com.mindflow.entity.Note;
import com.mindflow.vo.InterviewQuestionVO;

import java.util.List;
import java.util.Map;

/**
 * 笔记服务接口
 */
public interface NoteService extends IService<Note> {

    /** 创建笔记（含 AI 自动总结） */
    Map<String, Object> createNote(String content, String contentType);

    /** 分页查询笔记列表 */
    Map<String, Object> getNoteList(int pageNum, int pageSize, String category, String keyword);

    /** 笔记详情 */
    Map<String, Object> getNoteDetail(Long noteId);

    /** 删除笔记 */
    void deleteNote(Long noteId);

    /** 生成面试题 */
    List<InterviewQuestionVO> generateInterviewQuestions(Long noteId);

    /** 获取用户所有分类 */
    List<String> getCategories();

    /** 获取用户所有标签 */
    List<String> getTags();
}