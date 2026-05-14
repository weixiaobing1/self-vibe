package com.mindflow.controller;

import com.mindflow.common.Result;
import com.mindflow.dto.AiChatReq;
import com.mindflow.dto.GenerateInterviewReq;
import com.mindflow.service.AIService;
import com.mindflow.service.NoteService;
import com.mindflow.vo.ChatVO;
import com.mindflow.vo.GenerateInterviewVO;
import com.mindflow.vo.InterviewQuestionVO;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.servlet.mvc.method.annotation.SseEmitter;

import java.util.List;
import java.util.Map;
import java.util.UUID;

/**
 * AI 接口
 */
@RestController
@RequestMapping("/api/ai")
@Tag(name = "AI模块")
public class AIController {

    private final AIService aiService;
    private final NoteService noteService;

    public AIController(AIService aiService, NoteService noteService) {
        this.aiService = aiService;
        this.noteService = noteService;
    }

    @PostMapping("/summarize")
    @Operation(summary = "AI总结内容")
    public Result<Map<String, Object>> summarize(@RequestBody Map<String, String> body) {
        String content = body.get("content");
        return Result.success(aiService.summarize(content));
    }

    @PostMapping("/generate-interview")
    @Operation(summary = "生成面试题（入库）")
    public Result<GenerateInterviewVO> generateInterview(@RequestBody GenerateInterviewReq req) {
        List<InterviewQuestionVO> questions =
                noteService.generateInterviewQuestions(req.getNoteId());
        GenerateInterviewVO vo = new GenerateInterviewVO();
        vo.setQuestions(questions);
        return Result.success(vo);
    }

    @PostMapping("/explain-code")
    @Operation(summary = "AI解释代码")
    public Result<Map<String, Object>> explainCode(@RequestBody Map<String, String> body) {
        String code = body.get("code");
        return Result.success(aiService.explainCode(code));
    }

    @PostMapping("/chat")
    @Operation(summary = "AI对话（带上下文session）")
    public Result<ChatVO> chat(@RequestBody AiChatReq req) {
        String sessionId = req.getSessionId() != null && !req.getSessionId().isEmpty()
                ? req.getSessionId()
                : UUID.randomUUID().toString();
        String reply = aiService.chat(sessionId, req.getContent());
        ChatVO vo = new ChatVO();
        vo.setSessionId(sessionId);
        vo.setReply(reply);
        return Result.success(vo);
    }

    @PostMapping("/chat/stream")
    @Operation(summary = "AI流式对话（SSE）")
    public SseEmitter chatStream(@RequestBody AiChatReq req) {
        String sessionId = req.getSessionId() != null && !req.getSessionId().isEmpty()
                ? req.getSessionId()
                : UUID.randomUUID().toString();

        SseEmitter emitter = new SseEmitter(300000L);
        aiService.chatStream(sessionId, req.getContent(), emitter);
        return emitter;
    }

    @PostMapping("/generate-note")
    @Operation(summary = "AI帮写笔记，根据主题生成学习笔记")
    public Result<String> generateNote(@RequestBody Map<String, String> body) {
        String topic = body.get("topic");
        String note = aiService.generateNote(topic);
        return Result.success(note);
    }
}