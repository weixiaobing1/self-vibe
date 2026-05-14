package com.mindflow.controller;

import com.mindflow.common.Result;
import com.mindflow.dto.ChangePasswordReq;
import com.mindflow.dto.LoginReq;
import com.mindflow.dto.RegisterReq;
import com.mindflow.service.UserService;
import com.mindflow.vo.LoginVO;
import com.mindflow.vo.UserVO;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import org.springframework.web.bind.annotation.*;

import java.util.Map;

/**
 * 用户接口
 */
@RestController
@RequestMapping("/api/user")
@Tag(name = "用户模块")
public class UserController {

    private final UserService userService;

    public UserController(UserService userService) {
        this.userService = userService;
    }

    @PostMapping("/register")
    @Operation(summary = "用户注册")
    public Result<UserVO> register(@RequestBody RegisterReq req) {
        return Result.success(userService.register(req));
    }

    @PostMapping("/login")
    @Operation(summary = "用户登录")
    public Result<LoginVO> login(@RequestBody LoginReq req) {
        return Result.success(userService.login(req));
    }

    @PostMapping("/refresh-token")
    @Operation(summary = "刷新 Token")
    public Result<String> refreshToken(@RequestBody Map<String, String> body) {
        String refreshToken = body.get("refreshToken");
        return Result.success(userService.refreshToken(refreshToken));
    }

    @GetMapping("/info")
    @Operation(summary = "获取用户信息")
    public Result<UserVO> info() {
        return Result.success(userService.getUserInfo());
    }

    @PutMapping("/update")
    @Operation(summary = "更新用户信息")
    public Result<Void> update(@RequestBody UserVO vo) {
        userService.updateUserInfo(vo);
        return Result.success();
    }

    @PutMapping("/change-password")
    @Operation(summary = "修改密码")
    public Result<Void> changePassword(@RequestBody ChangePasswordReq req) {
        userService.changePassword(req);
        return Result.success();
    }
}