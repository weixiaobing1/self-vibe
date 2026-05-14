package com.mindflow.service;

import com.baomidou.mybatisplus.extension.service.IService;
import com.mindflow.dto.ChangePasswordReq;
import com.mindflow.dto.LoginReq;
import com.mindflow.dto.RegisterReq;
import com.mindflow.entity.User;
import com.mindflow.vo.LoginVO;
import com.mindflow.vo.UserVO;

/**
 * 用户服务接口
 */
public interface UserService extends IService<User> {

    /** 用户注册 */
    UserVO register(RegisterReq req);

    /** 用户登录 */
    LoginVO login(LoginReq req);

    /** 刷新 Token */
    String refreshToken(String refreshToken);

    /** 获取当前用户信息 */
    UserVO getUserInfo();

    /** 更新用户信息 */
    void updateUserInfo(UserVO vo);

    /** 修改密码 */
    void changePassword(ChangePasswordReq req);
}