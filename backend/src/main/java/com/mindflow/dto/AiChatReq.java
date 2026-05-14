package com.mindflow.dto;

/**
 * AI 对话请求
 */
public class AiChatReq {

    private String sessionId;
    private String content;

    public String getSessionId() { return sessionId; }
    public void setSessionId(String sessionId) { this.sessionId = sessionId; }
    public String getContent() { return content; }
    public void setContent(String content) { this.content = content; }
}