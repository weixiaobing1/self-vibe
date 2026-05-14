package com.mindflow.service.impl;

import cn.hutool.core.bean.BeanUtil;
import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.mindflow.common.ErrorCode;
import com.mindflow.dto.ChangePasswordReq;
import com.mindflow.dto.LoginReq;
import com.mindflow.dto.RegisterReq;
import com.mindflow.entity.User;
import com.mindflow.exception.BusinessException;
import com.mindflow.mapper.UserMapper;
import com.mindflow.service.UserService;
import com.mindflow.utils.JwtUtils;
import com.mindflow.utils.RedisUtils;
import com.mindflow.utils.UserContext;
import com.mindflow.vo.LoginVO;
import com.mindflow.vo.UserVO;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;

/**
 * 用户服务实现
 */
@Service
public class UserServiceImpl extends ServiceImpl<UserMapper, User> implements UserService {

    private final PasswordEncoder passwordEncoder;
    private final JwtUtils jwtUtils;
    private final RedisUtils redisUtils;

    public UserServiceImpl(PasswordEncoder passwordEncoder,
                           JwtUtils jwtUtils,
                           RedisUtils redisUtils) {
        this.passwordEncoder = passwordEncoder;
        this.jwtUtils = jwtUtils;
        this.redisUtils = redisUtils;
    }

    @Override
    public UserVO register(RegisterReq req) {
        User exist = getOne(new LambdaQueryWrapper<User>()
                .eq(User::getUsername, req.getUsername()));
        if (exist != null) {
            throw new BusinessException(ErrorCode.USERNAME_EXIST);
        }

        User user = new User();
        user.setUsername(req.getUsername());
        user.setPassword(passwordEncoder.encode(req.getPassword()));
        user.setNickname(req.getNickname() != null ? req.getNickname() : req.getUsername());
        save(user);

        return convertToVO(user);
    }

    @Override
    public LoginVO login(LoginReq req) {
        User user = getOne(new LambdaQueryWrapper<User>()
                .eq(User::getUsername, req.getUsername()));
        if (user == null) {
            throw new BusinessException(ErrorCode.USER_NOT_EXIST);
        }

        if (!passwordEncoder.matches(req.getPassword(), user.getPassword())) {
            throw new BusinessException(ErrorCode.PASSWORD_ERROR);
        }

        String accessToken = jwtUtils.generateAccessToken(user.getId(), user.getUsername());
        String refreshToken = jwtUtils.generateRefreshToken(user.getId(), user.getUsername());

        redisUtils.setAccessToken(user.getId(), accessToken);
        redisUtils.setRefreshToken(user.getId(), refreshToken);

        UserVO userVO = convertToVO(user);
        redisUtils.setUserInfo(user.getId(), userVO);

        return new LoginVO(accessToken, refreshToken, userVO);
    }

    @Override
    public String refreshToken(String refreshToken) {
        Long userId = jwtUtils.getUserId(refreshToken);

        String cachedRefresh = redisUtils.getRefreshToken(userId);
        if (cachedRefresh == null || !cachedRefresh.equals(refreshToken)) {
            throw new BusinessException(ErrorCode.UNAUTHORIZED);
        }

        if (jwtUtils.isTokenExpired(refreshToken)) {
            throw new BusinessException(ErrorCode.UNAUTHORIZED);
        }

        User user = getById(userId);
        String newAccessToken = jwtUtils.generateAccessToken(userId, user.getUsername());
        redisUtils.setAccessToken(userId, newAccessToken);

        return newAccessToken;
    }

    @Override
    public UserVO getUserInfo() {
        Long userId = UserContext.getUserId();

        Object cached = redisUtils.getUserInfo(userId);
        if (cached != null) {
            return BeanUtil.toBean(cached, UserVO.class);
        }

        User user = getById(userId);
        if (user == null) {
            throw new BusinessException(ErrorCode.USER_NOT_EXIST);
        }

        UserVO vo = convertToVO(user);
        redisUtils.setUserInfo(userId, vo);
        return vo;
    }

    @Override
    public void updateUserInfo(UserVO vo) {
        Long userId = UserContext.getUserId();

        User user = getById(userId);
        if (user == null) {
            throw new BusinessException(ErrorCode.USER_NOT_EXIST);
        }

        if (vo.getNickname() != null) user.setNickname(vo.getNickname());
        if (vo.getAvatar() != null) user.setAvatar(vo.getAvatar());
        if (vo.getEmail() != null) user.setEmail(vo.getEmail());
        if (vo.getAiModel() != null) user.setAiModel(vo.getAiModel());
        if (vo.getStudyTarget() != null) user.setStudyTarget(vo.getStudyTarget());

        updateById(user);

        redisUtils.deleteUserInfo(userId);
    }

    @Override
    public void changePassword(ChangePasswordReq req) {
        Long userId = UserContext.getUserId();
        User user = getById(userId);
        if (user == null) {
            throw new BusinessException(ErrorCode.USER_NOT_EXIST);
        }

        if (!passwordEncoder.matches(req.getOldPassword(), user.getPassword())) {
            throw new BusinessException(ErrorCode.PASSWORD_ERROR);
        }

        user.setPassword(passwordEncoder.encode(req.getNewPassword()));
        updateById(user);
    }

    private UserVO convertToVO(User user) {
        UserVO vo = new UserVO();
        vo.setId(user.getId());
        vo.setUsername(user.getUsername());
        vo.setNickname(user.getNickname());
        vo.setAvatar(user.getAvatar());
        vo.setEmail(user.getEmail());
        vo.setAiModel(user.getAiModel());
        vo.setStudyTarget(user.getStudyTarget());
        vo.setCreateTime(user.getCreateTime());
        return vo;
    }
}