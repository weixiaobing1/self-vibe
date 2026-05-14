package com.mindflow.dto;

/**
 * 创建笔记请求
 */
public class CreateNoteReq {

    private String content;
    private String contentType;

    public String getContent() { return content; }
    public void setContent(String content) { this.content = content; }
    public String getContentType() { return contentType; }
    public void setContentType(String contentType) { this.contentType = contentType; }
}