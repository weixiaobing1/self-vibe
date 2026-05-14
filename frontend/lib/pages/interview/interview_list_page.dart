import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../providers/interview_provider.dart';
import 'interview_practice_page.dart';

class InterviewListPage extends StatefulWidget {
  const InterviewListPage({super.key});

  @override
  State<InterviewListPage> createState() => _InterviewListPageState();
}

class _InterviewListPageState extends State<InterviewListPage> {
  final _levels = ['初级', '中级', '高级'];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<InterviewProvider>().loadQuestions();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('面试题库')),
      body: Column(
        children: [
          Consumer<InterviewProvider>(
            builder: (context, ip, _) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    ChoiceChip(
                      label: const Text('全部'),
                      selected: ip.levelFilter == null && ip.masteredFilter == null,
                      onSelected: (_) => ip.loadQuestions(),
                      selectedColor: AppTheme.accentColor.withValues(alpha: 0.3),
                      labelStyle: TextStyle(
                        color: ip.levelFilter == null && ip.masteredFilter == null
                            ? AppTheme.accentColor : AppTheme.textSecondary,
                        fontSize: 12,
                      ),
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      visualDensity: VisualDensity.compact,
                    ),
                    SizedBox(width: 6),
                    ..._levels.map((lvl) => Padding(
                      padding: const EdgeInsets.only(right: 6),
                      child: ChoiceChip(
                        label: Text(lvl),
                        selected: ip.levelFilter == lvl,
                        onSelected: (_) => ip.loadQuestions(level: lvl),
                        selectedColor: AppTheme.accentColor.withValues(alpha: 0.3),
                        labelStyle: TextStyle(
                          color: ip.levelFilter == lvl ? AppTheme.accentColor : AppTheme.textSecondary,
                          fontSize: 12,
                        ),
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        visualDensity: VisualDensity.compact,
                      ),
                    )),
                    const Spacer(),
                    ChoiceChip(
                      label: const Text('待掌握'),
                      selected: ip.masteredFilter == 0,
                      onSelected: (_) => ip.loadQuestions(isMastered: ip.masteredFilter == 0 ? null : 0),
                      selectedColor: AppTheme.warning.withValues(alpha: 0.3),
                      labelStyle: TextStyle(
                        color: ip.masteredFilter == 0 ? AppTheme.warning : AppTheme.textSecondary,
                        fontSize: 12,
                      ),
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      visualDensity: VisualDensity.compact,
                    ),
                    SizedBox(width: 6),
                    ChoiceChip(
                      label: const Text('已掌握'),
                      selected: ip.masteredFilter == 1,
                      onSelected: (_) => ip.loadQuestions(isMastered: ip.masteredFilter == 1 ? null : 1),
                      selectedColor: AppTheme.success.withValues(alpha: 0.3),
                      labelStyle: TextStyle(
                        color: ip.masteredFilter == 1 ? AppTheme.success : AppTheme.textSecondary,
                        fontSize: 12,
                      ),
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      visualDensity: VisualDensity.compact,
                    ),
                  ],
                ),
              );
            },
          ),
          Expanded(
            child: Consumer<InterviewProvider>(
              builder: (context, ip, _) {
                if (ip.isLoading && ip.questions.isEmpty) {
                  return Center(child: CircularProgressIndicator());
                }
                if (ip.questions.isEmpty) {
                  return Center(
                    child: Text('还没有面试题，先创建笔记并生成面试题吧',
                        style: TextStyle(color: AppTheme.textSecondary)),
                  );
                }
                return ListView.builder(
                  itemCount: ip.questions.length,
                  itemBuilder: (context, index) {
                    final q = ip.questions[index];
                    final levelColor = q.level == '初级' ? AppTheme.success : q.level == '中级' ? AppTheme.warning : AppTheme.error;
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      child: ListTile(
                        onTap: () => Navigator.push(context, MaterialPageRoute(
                          builder: (_) => InterviewPracticePage(question: q),
                        )),
                        title: Text(q.question ?? '', maxLines: 2, overflow: TextOverflow.ellipsis,
                            style: TextStyle(fontSize: 14, color: AppTheme.textPrimary)),
                        subtitle: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                              decoration: BoxDecoration(
                                color: levelColor.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(q.level ?? '', style: TextStyle(fontSize: 11, color: levelColor)),
                            ),
                            SizedBox(width: 8),
                            if (q.isMastered == 1)
                              Icon(Icons.check_circle, size: 16, color: AppTheme.success),
                          ],
                        ),
                        trailing: IconButton(
                          icon: Icon(
                            q.isMastered == 1 ? Icons.check_circle : Icons.check_circle_outline,
                            color: q.isMastered == 1 ? AppTheme.success : AppTheme.textSecondary,
                          ),
                          onPressed: () => ip.toggleMastered(q.id),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}