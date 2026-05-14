package com.mindflow.common;

/**
 * 错误码枚举
 */
public enum ErrorCode {

    SUCCESS(200, "操作成功"),
    PARAM_ERROR(400, "参数错误"),
    UNAUTHORIZED(401, "未登录或 Token 已过期"),
    FORBIDDEN(403, "无权限访问"),
    NOT_FOUND(404, "资源不存在"),
    SERVER_ERROR(500, "服务器内部错误"),

    // 业务错误码
    USER_NOT_EXIST(1001, "用户不存在"),
    USERNAME_EXIST(1002, "用户名已存在"),
    PASSWORD_ERROR(1003, "密码错误"),

    // AI 相关
    AI_SERVICE_ERROR(5001, "AI 服务调用失败"),

    // 文件相关
    FILE_UPLOAD_ERROR(5002, "文件上传失败");

    private final int code;
    private final String message;

    ErrorCode(int code, String message) {
        this.code = code;
        this.message = message;
    }

    public int getCode() { return code; }
    public String getMessage() { return message; }
}