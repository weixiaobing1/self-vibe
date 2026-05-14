package com.mindflow.controller;

import com.mindflow.common.Result;
import com.mindflow.dto.CreateNoteReq;
import com.mindflow.service.NoteService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

/**
 * 笔记接口
 */
@RestController
@RequestMapping("/api/note")
@Tag(name = "笔记模块")
public class NoteController {

    private final NoteService noteService;

    public NoteController(NoteService noteService) {
        this.noteService = noteService;
    }

    @PostMapping("/create")
    @Operation(summary = "创建笔记（含AI自动总结）")
    public Result<Map<String, Object>> create(@RequestBody CreateNoteReq req) {
        return Result.success(noteService.createNote(req.getContent(), req.getContentType()));
    }

    @GetMapping("/list")
    @Operation(summary = "获取笔记列表")
    public Result<Map<String, Object>> list(@RequestParam(defaultValue = "1") int pageNum,
                                             @RequestParam(defaultValue = "10") int pageSize,
                                             @RequestParam(required = false) String category,
                                             @RequestParam(required = false) String keyword) {
        return Result.success(noteService.getNoteList(pageNum, pageSize, category, keyword));
    }

    @GetMapping("/detail/{id}")
    @Operation(summary = "获取笔记详情")
    public Result<Map<String, Object>> detail(@PathVariable Long id) {
        return Result.success(noteService.getNoteDetail(id));
    }

    @DeleteMapping("/delete/{id}")
    @Operation(summary = "删除笔记")
    public Result<Void> delete(@PathVariable Long id) {
        noteService.deleteNote(id);
        return Result.success();
    }

    @GetMapping("/categories")
    @Operation(summary = "获取用户所有分类")
    public Result<List<String>> categories() {
        return Result.success(noteService.getCategories());
    }

    @GetMapping("/tags")
    @Operation(summary = "获取用户所有标签")
    public Result<List<String>> tags() {
        return Result.success(noteService.getTags());
    }
}