package com.mindflow.service;

import org.springframework.web.servlet.mvc.method.annotation.SseEmitter;

import java.util.Map;

/**
 * AI 服务接口
 */
public interface AIService {

    /** 总结学习内容，返回 {summary, keyPoints, category, tags, difficulty, studySuggestion} */
    Map<String, Object> summarize(String content);

    /** 生成面试题，返回 {questions: [{question, answer, level}]} */
    Map<String, Object> generateInterview(String knowledge, String difficulty);

    /** 解释代码，返回 {codeFunction, logicAnalysis, knowledgePoints, possibleProblems, optimizationSuggestions} */
    Map<String, Object> explainCode(String code);

    /** AI 对话（带上下文 session），返回助手回复文本 */
    String chat(String sessionId, String content);

    /** AI 流式对话（SSE），逐字推送到前端 */
    void chatStream(String sessionId, String content, SseEmitter emitter);

    /** AI 帮写笔记，根据主题生成学习笔记（返回 Markdown 文本） */
    String generateNote(String topic);
}