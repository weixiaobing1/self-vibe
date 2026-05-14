package com.mindflow.service.impl;

import cn.hutool.crypto.digest.DigestUtil;
import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.fasterxml.jackson.datatype.jsr310.JavaTimeModule;
import com.mindflow.common.ErrorCode;
import com.mindflow.entity.AiChat;
import com.mindflow.exception.BusinessException;
import com.mindflow.mapper.AiChatMapper;
import com.mindflow.service.AIService;
import com.mindflow.utils.RedisUtils;
import com.mindflow.utils.UserContext;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.ai.chat.messages.AssistantMessage;
import org.springframework.ai.chat.messages.Message;
import org.springframework.ai.chat.messages.UserMessage;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.core.io.ClassPathResource;
import org.springframework.stereotype.Service;
import org.springframework.web.servlet.mvc.method.annotation.SseEmitter;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;
import java.io.OutputStream;
import java.net.HttpURLConnection;
import java.net.URL;
import java.nio.charset.StandardCharsets;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.concurrent.TimeUnit;

/**
 * AI 服务实现 - 基于 Spring AI ChatClient
 */
@Service
public class AIServiceImpl implements AIService {

    private static final Logger log = LoggerFactory.getLogger(AIServiceImpl.class);
    private static final int MAX_RETRIES = 3;
    private static final int MAX_CONTEXT_MESSAGES = 20;

    private final RedisUtils redisUtils;
    private final AiChatMapper aiChatMapper;
    private final ObjectMapper objectMapper;

    @Value("${spring.ai.openai.api-key}")
    private String apiKey;

    @Value("${spring.ai.openai.base-url}")
    private String deepseekBaseUrl;

    @Value("${spring.ai.openai.chat.options.model}")
    private String model;

    @Value("${spring.ai.openai.chat.options.temperature}")
    private double temperature;

    private String summarizePrompt;
    private String interviewPrompt;
    private String explainCodePrompt;
    private String generateNotePrompt;

    public AIServiceImpl(RedisUtils redisUtils, AiChatMapper aiChatMapper) {
        this.redisUtils = redisUtils;
        this.aiChatMapper = aiChatMapper;
        this.objectMapper = new ObjectMapper();
        this.objectMapper.registerModule(new JavaTimeModule());
        loadPrompts();
    }

    private void loadPrompts() {
        summarizePrompt = loadPrompt("prompts/summarize_note.txt");
        interviewPrompt = loadPrompt("prompts/generate_interview.txt");
        explainCodePrompt = loadPrompt("prompts/explain_code.txt");
        generateNotePrompt = loadPrompt("prompts/generate_note.txt");
    }

    private String loadPrompt(String path) {
        try {
            ClassPathResource resource = new ClassPathResource(path);
            return new String(resource.getInputStream().readAllBytes(), StandardCharsets.UTF_8);
        } catch (Exception e) {
            throw new RuntimeException("Failed to load prompt: " + path, e);
        }
    }

    @Override
    public Map<String, Object> summarize(String content) {
        String hash = DigestUtil.md5Hex(content);
        String cacheKey = "ai:cache:summarize:" + hash;

        Object cached = redisUtils.get(cacheKey);
        if (cached != null) {
            return objectMapper.convertValue(cached, new TypeReference<Map<String, Object>>() {});
        }

        String prompt = summarizePrompt.replace("{{content}}", content);
        String response = callWithRetry(List.of(new UserMessage(prompt)));
        Map<String, Object> result = parseJsonResponse(response);

        redisUtils.set(cacheKey, result, 1, TimeUnit.HOURS);
        return result;
    }

    @Override
    public Map<String, Object> generateInterview(String knowledge, String difficulty) {
        String prompt = interviewPrompt
                .replace("{{knowledge}}", knowledge)
                .replace("{{difficulty}}", difficulty != null ? difficulty : "初级");
        String response = callWithRetry(List.of(new UserMessage(prompt)));
        return parseJsonResponse(response);
    }

    @Override
    public Map<String, Object> explainCode(String code) {
        String prompt = explainCodePrompt.replace("{{code}}", code);
        String response = callWithRetry(List.of(new UserMessage(prompt)));
        return parseJsonResponse(response);
    }

    @Override
    public String generateNote(String topic) {
        String prompt = generateNotePrompt.replace("{{topic}}", topic);
        return callWithRetry(List.of(new UserMessage(prompt)));
    }

    @Override
    public String chat(String sessionId, String content) {
        Long userId = UserContext.getUserId();

        List<Map<String, Object>> context = redisUtils.getChatContext(sessionId);

        List<Message> messages = new ArrayList<>();
        for (Map<String, Object> msg : context) {
            String role = (String) msg.get("role");
            String msgContent = (String) msg.get("content");
            if ("user".equals(role)) {
                messages.add(new UserMessage(msgContent));
            } else if ("assistant".equals(role)) {
                messages.add(new AssistantMessage(msgContent));
            }
        }
        messages.add(new UserMessage(content));

        AiChat userMsg = new AiChat();
        userMsg.setUserId(userId);
        userMsg.setSessionId(sessionId);
        userMsg.setRole("user");
        userMsg.setContent(content);
        aiChatMapper.insert(userMsg);

        String reply = callWithRetry(messages);

        AiChat assistantMsg = new AiChat();
        assistantMsg.setUserId(userId);
        assistantMsg.setSessionId(sessionId);
        assistantMsg.setRole("assistant");
        assistantMsg.setContent(reply);
        aiChatMapper.insert(assistantMsg);

        updateContext(sessionId, context, content, reply);
        return reply;
    }

    @Override
    public void chatStream(String sessionId, String content, SseEmitter emitter) {
        Long userId = UserContext.getUserId();

        List<Map<String, Object>> context = redisUtils.getChatContext(sessionId);

        // Build messages for DeepSeek API format
        List<Map<String, String>> apiMessages = new ArrayList<>();
        for (Map<String, Object> msg : context) {
            apiMessages.add(Map.of(
                "role", (String) msg.get("role"),
                "content", (String) msg.get("content")
            ));
        }
        apiMessages.add(Map.of("role", "user", "content", content));

        // Save user message
        AiChat userMsg = new AiChat();
        userMsg.setUserId(userId);
        userMsg.setSessionId(sessionId);
        userMsg.setRole("user");
        userMsg.setContent(content);
        aiChatMapper.insert(userMsg);

        // Run HTTP reading in separate thread so controller returns emitter immediately
        new Thread(() -> {
            StringBuilder fullReply = new StringBuilder();
            try {
                String requestBody = buildStreamRequestBody(apiMessages);
                HttpURLConnection conn = openDeepSeekConnection(requestBody);

                try (BufferedReader reader = new BufferedReader(
                        new InputStreamReader(conn.getInputStream(), StandardCharsets.UTF_8))) {
                    String line;
                    while ((line = reader.readLine()) != null) {
                        if (!line.startsWith("data: ")) continue;
                        String data = line.substring(6);
                        if ("[DONE]".equals(data)) break;

                        String token = extractContentDelta(data);
                        if (token != null) {
                            fullReply.append(token);
                            emitter.send(SseEmitter.event().data(token));
                        }
                    }
                }

                // Persist assistant message
                String reply = fullReply.toString();
                AiChat assistantMsg = new AiChat();
                assistantMsg.setUserId(userId);
                assistantMsg.setSessionId(sessionId);
                assistantMsg.setRole("assistant");
                assistantMsg.setContent(reply);
                aiChatMapper.insert(assistantMsg);

                updateContext(sessionId, context, content, reply);
                emitter.complete();
                log.info("Stream chat completed, session={}, reply length={}", sessionId, reply.length());
            } catch (Exception e) {
                log.error("Stream chat failed, session={}", sessionId, e);
                try {
                    emitter.completeWithError(e);
                } catch (Exception ignored) {
                    // emitter may already be closed
                }
            }
        }, "deepseek-sse-" + sessionId).start();
    }

    // ==================== DeepSeek SSE helpers ====================

    private String buildStreamRequestBody(List<Map<String, String>> messages) throws Exception {
        Map<String, Object> body = new HashMap<>();
        body.put("model", model);
        body.put("messages", messages);
        body.put("stream", true);
        body.put("temperature", temperature);
        return objectMapper.writeValueAsString(body);
    }

    private HttpURLConnection openDeepSeekConnection(String requestBody) throws IOException {
        URL url = new URL(deepseekBaseUrl + "/v1/chat/completions");
        HttpURLConnection conn = (HttpURLConnection) url.openConnection();
        conn.setRequestMethod("POST");
        conn.setRequestProperty("Content-Type", "application/json");
        conn.setRequestProperty("Authorization", "Bearer " + apiKey);
        conn.setRequestProperty("Accept", "text/event-stream");
        conn.setDoOutput(true);
        conn.setConnectTimeout(10000);
        conn.setReadTimeout(300000);
        try (OutputStream os = conn.getOutputStream()) {
            os.write(requestBody.getBytes(StandardCharsets.UTF_8));
        }
        return conn;
    }

    private String extractContentDelta(String jsonData) {
        try {
            JsonNode root = objectMapper.readTree(jsonData);
            JsonNode choices = root.get("choices");
            if (choices != null && choices.isArray() && choices.size() > 0) {
                JsonNode delta = choices.get(0).get("delta");
                if (delta != null && delta.has("content")) {
                    String token = delta.get("content").asText();
                    if (token != null && !token.isEmpty()) {
                        return token;
                    }
                }
            }
        } catch (Exception e) {
            log.debug("Failed to parse SSE data: {}", jsonData);
        }
        return null;
    }

    // ==================== 内部方法 ====================

    private String callWithRetry(List<Message> messages) {
        // Convert Spring AI Messages to plain Maps for direct HTTP call
        List<Map<String, String>> apiMessages = new ArrayList<>();
        for (Message msg : messages) {
            String role;
            String content;
            if (msg instanceof UserMessage) {
                role = "user";
                content = ((UserMessage) msg).getText();
            } else if (msg instanceof AssistantMessage) {
                role = "assistant";
                content = ((AssistantMessage) msg).getText();
            } else {
                role = msg.getMessageType().name().toLowerCase();
                content = msg.toString();
            }
            apiMessages.add(Map.of("role", role, "content", content));
        }

        for (int i = 0; i < MAX_RETRIES; i++) {
            try {
                return callDeepSeek(apiMessages);
            } catch (BusinessException e) {
                throw e;
            } catch (Exception e) {
                log.warn("AI API call failed, attempt {}/{}: {}", i + 1, MAX_RETRIES, e.getMessage());
                if (i == MAX_RETRIES - 1) {
                    log.error("AI API call exhausted all {} retries", MAX_RETRIES);
                    throw new BusinessException(ErrorCode.AI_SERVICE_ERROR);
                }
                try {
                    Thread.sleep((long) Math.pow(2, i) * 1000);
                } catch (InterruptedException ie) {
                    Thread.currentThread().interrupt();
                    throw new BusinessException(ErrorCode.AI_SERVICE_ERROR);
                }
            }
        }
        throw new BusinessException(ErrorCode.AI_SERVICE_ERROR);
    }

    /** Direct HTTP call to DeepSeek API (non-streaming), returns full response content */
    private String callDeepSeek(List<Map<String, String>> messages) throws IOException {
        Map<String, Object> body = new HashMap<>();
        body.put("model", model);
        body.put("messages", messages);
        body.put("stream", false);
        body.put("temperature", temperature);

        String requestBody = objectMapper.writeValueAsString(body);

        URL url = new URL(deepseekBaseUrl + "/v1/chat/completions");
        HttpURLConnection conn = (HttpURLConnection) url.openConnection();
        conn.setRequestMethod("POST");
        conn.setRequestProperty("Content-Type", "application/json");
        conn.setRequestProperty("Authorization", "Bearer " + apiKey);
        conn.setDoOutput(true);
        conn.setConnectTimeout(30000);
        conn.setReadTimeout(300000);

        try (OutputStream os = conn.getOutputStream()) {
            os.write(requestBody.getBytes(StandardCharsets.UTF_8));
        }

        String responseBody;
        try (BufferedReader reader = new BufferedReader(
                new InputStreamReader(conn.getInputStream(), StandardCharsets.UTF_8))) {
            StringBuilder sb = new StringBuilder();
            String line;
            while ((line = reader.readLine()) != null) {
                sb.append(line);
            }
            responseBody = sb.toString();
        }

        // Check for API error response
        JsonNode root = objectMapper.readTree(responseBody);
        if (root.has("error")) {
            String errMsg = root.get("error").has("message")
                    ? root.get("error").get("message").asText()
                    : responseBody;
            log.error("DeepSeek API error: {}", errMsg);
            throw new IOException("DeepSeek API error: " + errMsg);
        }

        JsonNode choices = root.get("choices");
        if (choices != null && choices.isArray() && choices.size() > 0) {
            JsonNode message = choices.get(0).get("message");
            if (message != null && message.has("content")) {
                String content = message.get("content").asText();
                if (content != null && !content.isEmpty()) {
                    return content;
                }
            }
        }

        throw new IOException("Empty response from DeepSeek API");
    }

    private void updateContext(String sessionId, List<Map<String, Object>> context,
                               String userContent, String assistantContent) {
        Map<String, Object> userEntry = new HashMap<>();
        userEntry.put("role", "user");
        userEntry.put("content", userContent);
        Map<String, Object> assistantEntry = new HashMap<>();
        assistantEntry.put("role", "assistant");
        assistantEntry.put("content", assistantContent);

        context.add(userEntry);
        context.add(assistantEntry);
        if (context.size() > MAX_CONTEXT_MESSAGES) {
            context = context.subList(context.size() - MAX_CONTEXT_MESSAGES, context.size());
        }
        redisUtils.setChatContext(sessionId, context);
    }

    private Map<String, Object> parseJsonResponse(String aiResponse) {
        try {
            String json = aiResponse.trim();
            if (json.startsWith("```")) {
                json = json.replaceAll("```json\\s*", "").replaceAll("```\\s*", "").trim();
            }
            return objectMapper.readValue(json, new TypeReference<Map<String, Object>>() {});
        } catch (Exception e) {
            log.error("Failed to parse AI JSON response: {}", aiResponse);
            throw new BusinessException(ErrorCode.AI_SERVICE_ERROR);
        }
    }
}