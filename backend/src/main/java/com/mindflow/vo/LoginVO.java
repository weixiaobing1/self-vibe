package com.mindflow.vo;

/**
 * 登录响应
 */
public class LoginVO {

    private String accessToken;
    private String refreshToken;
    private UserVO userInfo;

    public LoginVO() {}

    public LoginVO(String accessToken, String refreshToken, UserVO userInfo) {
        this.accessToken = accessToken;
        this.refreshToken = refreshToken;
        this.userInfo = userInfo;
    }

    public String getAccessToken() { return accessToken; }
    public void setAccessToken(String accessToken) { this.accessToken = accessToken; }
    public String getRefreshToken() { return refreshToken; }
    public void setRefreshToken(String refreshToken) { this.refreshToken = refreshToken; }
    public UserVO getUserInfo() { return userInfo; }
    public void setUserInfo(UserVO userInfo) { this.userInfo = userInfo; }
}