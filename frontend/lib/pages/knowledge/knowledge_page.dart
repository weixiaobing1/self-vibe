import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../providers/note_provider.dart';
import '../../widgets/note_card.dart';
import '../interview/interview_list_page.dart';
import 'note_detail_page.dart';
import 'note_create_page.dart';

class KnowledgePage extends StatefulWidget {
  const KnowledgePage({super.key});

  @override
  State<KnowledgePage> createState() => _KnowledgePageState();
}

class _KnowledgePageState extends State<KnowledgePage> {
  final _searchCtrl = TextEditingController();
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final noteProvider = context.read<NoteProvider>();
      noteProvider.loadNotes();
      noteProvider.loadCategories();
      noteProvider.loadTags();
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String keyword) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      context.read<NoteProvider>().loadNotes(keyword: keyword.trim().isEmpty ? null : keyword.trim());
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('知识库'),
        actions: [
          IconButton(
            icon: const Icon(Icons.quiz_outlined),
            tooltip: '面试练习',
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const InterviewListPage()));
            },
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () async {
              final created = await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const NoteCreatePage()),
              );
              if (created == true) {
                if (context.mounted) context.read<NoteProvider>().loadNotes();
              }
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchCtrl,
              decoration: InputDecoration(
                hintText: '搜索笔记内容...',
                prefixIcon: Icon(Icons.search, color: AppTheme.textSecondary),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchCtrl.clear();
                    _debounce?.cancel();
                    context.read<NoteProvider>().loadNotes();
                  },
                ),
              ),
              onChanged: _onSearchChanged,
              onSubmitted: (keyword) => context.read<NoteProvider>().loadNotes(keyword: keyword),
            ),
          ),
          Consumer<NoteProvider>(
            builder: (context, np, _) {
              if (np.categories.isEmpty && np.tags.isEmpty) return const SizedBox.shrink();
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (np.categories.isNotEmpty)
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            ChoiceChip(
                              label: const Text('全部'),
                              selected: np.selectedCategory == null && np.selectedTag == null,
                              onSelected: (_) => np.setCategory(null),
                              selectedColor: AppTheme.accentColor.withValues(alpha: 0.3),
                              labelStyle: TextStyle(
                                color: np.selectedCategory == null && np.selectedTag == null
                                    ? AppTheme.accentColor : AppTheme.textSecondary,
                                fontSize: 12,
                              ),
                              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              visualDensity: VisualDensity.compact,
                            ),
                            SizedBox(width: 6),
                            ...np.categories.map((cat) => Padding(
                              padding: const EdgeInsets.only(right: 6),
                              child: ChoiceChip(
                                label: Text(cat),
                                selected: np.selectedCategory == cat,
                                onSelected: (_) => np.setCategory(cat),
                                selectedColor: AppTheme.accentColor.withValues(alpha: 0.3),
                                labelStyle: TextStyle(
                                  color: np.selectedCategory == cat ? AppTheme.accentColor : AppTheme.textSecondary,
                                  fontSize: 12,
                                ),
                                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                visualDensity: VisualDensity.compact,
                              ),
                            )),
                          ],
                        ),
                      ),
                    if (np.tags.isNotEmpty) ...[
                      SizedBox(height: 8),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: np.tags.map((tag) => Padding(
                            padding: const EdgeInsets.only(right: 6),
                            child: ChoiceChip(
                              label: Text('#$tag', style: const TextStyle(fontSize: 11)),
                              selected: np.selectedTag == tag,
                              onSelected: (_) => np.setTag(tag),
                              selectedColor: AppTheme.accentColor.withValues(alpha: 0.3),
                              labelStyle: TextStyle(
                                color: np.selectedTag == tag ? AppTheme.accentColor : AppTheme.textSecondary,
                                fontSize: 11,
                              ),
                              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              visualDensity: VisualDensity.compact,
                            ),
                          )).toList(),
                        ),
                      ),
                      SizedBox(height: 8),
                    ],
                  ],
                ),
              );
            },
          ),
          Expanded(
            child: Consumer<NoteProvider>(
              builder: (context, noteProvider, _) {
                if (noteProvider.isLoading && noteProvider.notes.isEmpty) {
                  return Center(child: CircularProgressIndicator());
                }
                if (noteProvider.error != null && noteProvider.notes.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(noteProvider.error!, style: TextStyle(color: AppTheme.error, fontSize: 13)),
                          const SizedBox(height: 12),
                          ElevatedButton(onPressed: () => noteProvider.loadNotes(), child: const Text('重试')),
                        ],
                      ),
                    ),
                  );
                }
                if (noteProvider.notes.isEmpty) {
                  return Center(child: Text('还没有笔记', style: TextStyle(color: AppTheme.textSecondary)));
                }
                return RefreshIndicator(
                  onRefresh: () => noteProvider.loadNotes(),
                  child: ListView.builder(
                    itemCount: noteProvider.notes.length,
                    itemBuilder: (context, index) {
                      final note = noteProvider.notes[index];
                      return NoteCard(
                        note: note,
                        onTap: () => Navigator.push(context,
                            MaterialPageRoute(builder: (_) => NoteDetailPage(noteId: note.id))),
                        onDelete: () => _confirmDelete(note.id),
                        onTagTap: (tag) => context.read<NoteProvider>().setTag(tag),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(int id) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('确认删除'),
        content: const Text('删除后不可恢复'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('取消')),
          ElevatedButton(
            onPressed: () {
              context.read<NoteProvider>().deleteNote(id);
              Navigator.pop(ctx);
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.error),
            child: const Text('删除'),
          ),
        ],
      ),
    );
  }
}