import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'providers/chat_provider.dart';
import 'providers/note_provider.dart';
import 'providers/review_provider.dart';
import 'providers/statistics_provider.dart';
import 'providers/interview_provider.dart';
import 'providers/mock_interview_provider.dart';
import 'providers/quiz_provider.dart';
import 'providers/theme_provider.dart';
import 'widgets/bottom_nav.dart';
import 'pages/home/home_page.dart';
import 'pages/knowledge/knowledge_page.dart';
import 'pages/ai_chat/ai_chat_page.dart';
import 'pages/statistics/statistics_page.dart';
import 'pages/profile/profile_page.dart';
import 'pages/login/login_page.dart';
import 'services/api_service.dart';
import 'services/notification_service.dart';

final _scaffoldKey = GlobalKey<ScaffoldMessengerState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService().init();

  ApiService.onNetworkError = (msg) {
    _scaffoldKey.currentState?.showSnackBar(
      SnackBar(content: Text(msg), duration: const Duration(seconds: 3)),
    );
  };

  runApp(const MindFlowApp());
}

class MindFlowApp extends StatelessWidget {
  const MindFlowApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => NoteProvider()),
        ChangeNotifierProvider(create: (_) => ChatProvider()),
        ChangeNotifierProvider(create: (_) => ReviewProvider()),
        ChangeNotifierProvider(create: (_) => StatisticsProvider()),
        ChangeNotifierProvider(create: (_) => InterviewProvider()),
        ChangeNotifierProvider(create: (_) => MockInterviewProvider()),
        ChangeNotifierProvider(create: (_) => QuizProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, _) {
          return MaterialApp(
            title: 'MindFlow AI',
            debugShowCheckedModeBanner: false,
            theme: themeProvider.theme,
            scaffoldMessengerKey: _scaffoldKey,
            home: const AppShell(),
          );
        },
      ),
    );
  }
}

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _currentIndex = 0;

  final List<Widget> _pages = const [
    HomePage(),
    KnowledgePage(),
    AIChatPage(),
    StatisticsPage(),
    ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, auth, _) {
        if (!auth.isLoggedIn) {
          return const LoginPage();
        }

        return Scaffold(
          body: IndexedStack(index: _currentIndex, children: _pages),
          bottomNavigationBar: BottomNav(
            currentIndex: _currentIndex,
            onTap: (index) => setState(() => _currentIndex = index),
          ),
        );
      },
    );
  }
}