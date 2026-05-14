import 'package:flutter/material.dart';
import '../config/theme.dart';
import '../models/note.dart';

class NoteCard extends StatelessWidget {
  final Note note;
  final VoidCallback onTap;
  final VoidCallback? onDelete;
  final void Function(String tag)? onTagTap;

  const NoteCard({super.key, required this.note, required this.onTap, this.onDelete, this.onTagTap});

  @override
  Widget build(BuildContext context) {
    final tagList = _parseTags(note.tags);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  if (note.category != null)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppTheme.accentColor.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(note.category!, style: TextStyle(fontSize: 12, color: AppTheme.accentColor)),
                    ),
                  const Spacer(),
                  if (note.difficulty != null)
                    Text(note.difficulty!, style: TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
                  if (onDelete != null) ...[
                    SizedBox(width: 8),
                    GestureDetector(
                      onTap: onDelete,
                      child: Icon(Icons.delete_outline, size: 18, color: AppTheme.textSecondary),
                    ),
                  ],
                ],
              ),
              SizedBox(height: 8),
              if (note.summary != null)
                Text(note.summary!, maxLines: 2, overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 15, color: AppTheme.textPrimary)),
              SizedBox(height: 6),
              Text(note.content ?? '', maxLines: 3, overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 13, color: AppTheme.textSecondary)),
              if (tagList.isNotEmpty) ...[
                SizedBox(height: 8),
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: tagList.map((tag) => GestureDetector(
                    onTap: () => onTagTap?.call(tag),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppTheme.accentColor.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text('#$tag', style: TextStyle(fontSize: 11, color: AppTheme.accentColor)),
                    ),
                  )).toList(),
                ),
              ],
              SizedBox(height: 8),
              Text(note.createTime ?? '', style: TextStyle(fontSize: 11, color: AppTheme.textSecondary)),
            ],
          ),
        ),
      ),
    );
  }

  List<String> _parseTags(String? tagsStr) {
    if (tagsStr == null || tagsStr.isEmpty) return [];
    return tagsStr.split(',').map((t) => t.trim()).where((t) => t.isNotEmpty).toList();
  }
}