import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import '../models/note.dart';
import '../services/note_service.dart';
import '../services/api_service.dart';

class NoteProvider extends ChangeNotifier {
  final NoteService _noteService = NoteService();

  List<Note> _notes = [];
  NoteDetail? _currentNote;
  bool _isLoading = false;
  int _total = 0;
  int _pageNum = 1;
  String? _category;
  String? _keyword;
  String? _error;

  List<String> _categories = [];
  List<String> _tags = [];
  String? _selectedCategory;
  String? _selectedTag;

  List<Note> get notes => _notes;
  NoteDetail? get currentNote => _currentNote;
  bool get isLoading => _isLoading;
  int get total => _total;
  String? get category => _category;
  String? get error => _error;
  List<String> get categories => _categories;
  List<String> get tags => _tags;
  String? get selectedCategory => _selectedCategory;
  String? get selectedTag => _selectedTag;

  Future<void> loadNotes({String? category, String? keyword}) async {
    _isLoading = true;
    _error = null;
    _category = category;
    _keyword = keyword;
    notifyListeners();

    try {
      final result = await _noteService.getNoteList(
        category: category,
        keyword: keyword,
      );
      _notes = result['list'] as List<Note>;
      _total = result['total'] as int;
    } catch (e) {
      _error = e is DioException ? ApiService.extractError(e) : '加载笔记失败';
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> loadMore() async {
    if (_notes.length >= _total) return;

    _pageNum++;
    try {
      final result = await _noteService.getNoteList(
        pageNum: _pageNum,
        category: _category,
        keyword: _keyword,
      );
      _notes.addAll(result['list'] as List<Note>);
      _total = result['total'] as int;
      notifyListeners();
    } catch (_) {
      _pageNum--;
    }
  }

  Future<Map<String, dynamic>?> createNote(String content) async {
    try {
      final result = await _noteService.createNote(content);
      await loadNotes();
      return result;
    } catch (_) {
      return null;
    }
  }

  Future<void> loadNoteDetail(int id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _currentNote = await _noteService.getNoteDetail(id);
    } catch (e) {
      _error = e is DioException ? ApiService.extractError(e) : '加载笔记详情失败';
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> deleteNote(int id) async {
    await _noteService.deleteNote(id);
    _notes.removeWhere((n) => n.id == id);
    notifyListeners();
  }

  Future<void> loadCategories() async {
    try {
      _categories = await _noteService.getCategories();
      notifyListeners();
    } catch (_) {}
  }

  Future<void> loadTags() async {
    try {
      _tags = await _noteService.getTags();
      notifyListeners();
    } catch (_) {}
  }

  void setCategory(String? category) {
    _selectedCategory = category == _selectedCategory ? null : category;
    _selectedTag = null;
    _pageNum = 1;
    loadNotes(category: _selectedCategory, keyword: _selectedTag);
  }

  void setTag(String? tag) {
    _selectedTag = tag == _selectedTag ? null : tag;
    _selectedCategory = null;
    _pageNum = 1;
    loadNotes(keyword: _selectedTag);
  }
}