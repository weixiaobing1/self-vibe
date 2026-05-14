import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../providers/auth_provider.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _usernameCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _nicknameCtrl = TextEditingController();
  bool _isLogin = true;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _usernameCtrl.dispose();
    _passwordCtrl.dispose();
    _nicknameCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final auth = context.read<AuthProvider>();
    final username = _usernameCtrl.text.trim();
    final password = _passwordCtrl.text.trim();

    if (username.isEmpty || password.isEmpty) return;

    bool success;
    if (_isLogin) {
      success = await auth.login(username, password);
    } else {
      final nickname = _nicknameCtrl.text.trim();
      if (nickname.isEmpty) return;
      success = await auth.register(username, password, nickname);
    }

    if (success && mounted) {
      context.read<AuthProvider>().loadUserInfo();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Consumer<AuthProvider>(
              builder: (context, auth, _) {
                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.psychology, size: 72, color: AppTheme.accentColor),
                    SizedBox(height: 16),
                    Text('MindFlow AI',
                        style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
                    SizedBox(height: 8),
                    Text('AI 驱动的学习助手',
                        style: TextStyle(fontSize: 14, color: AppTheme.textSecondary)),
                    SizedBox(height: 48),
                    TextField(
                      controller: _usernameCtrl,
                      decoration: const InputDecoration(hintText: '用户名'),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _passwordCtrl,
                      obscureText: _obscurePassword,
                      decoration: InputDecoration(
                        hintText: '密码',
                        suffixIcon: IconButton(
                          icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility),
                          onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                        ),
                      ),
                    ),
                    if (!_isLogin) ...[
                      const SizedBox(height: 16),
                      TextField(
                        controller: _nicknameCtrl,
                        decoration: const InputDecoration(hintText: '昵称'),
                      ),
                    ],
                    const SizedBox(height: 8),
                    if (auth.error != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(auth.error!, style: TextStyle(color: AppTheme.error, fontSize: 13)),
                      ),
                    SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: auth.isLoading ? null : _submit,
                        child: auth.isLoading
                            ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                            : Text(_isLogin ? '登录' : '注册', style: const TextStyle(fontSize: 16)),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _isLogin = !_isLogin;
                          auth.clearError();
                        });
                      },
                      child: Text(_isLogin ? '没有账号？去注册' : '已有账号？去登录',
                          style: TextStyle(color: AppTheme.textSecondary)),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}