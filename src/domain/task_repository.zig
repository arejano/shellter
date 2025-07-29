const std = @import("std");
const sqlite = @import("sqlite");

const Database = @import("database.zig");
const BaseRepository = @import("repository.zig").Repository;

pub const Task = struct {
    id: ?i64 = null,
    title: []const u8,
    description: []const u8,
    status: TaskStatus = .open,
    project_id: ?i64 = null,
    due_date: ?i64 = null,
    created_at: i64,

    pub const TaskStatus = enum {
        open,
        in_progress,
        done,
    };
};

pub const TaskRepository = struct {
    base: BaseRepository(Task),
    
    const Self = @This();

    pub fn init(db: *Database) Self {
        return .{
            .base = BaseRepository(Task).init(db),
        };
    }

    // Métodos específicos do TaskRepository
    pub fn create_table(self: *Self) !void {
        const query =
            \\CREATE TABLE IF NOT EXISTS tasks (
            \\    id INTEGER PRIMARY KEY AUTOINCREMENT,
            \\    title TEXT NOT NULL,
            \\    description TEXT,
            \\    status TEXT NOT NULL,
            \\    project_id INTEGER,
            \\    due_date INTEGER,
            \\    created_at INTEGER NOT NULL,
            \\    FOREIGN KEY(project_id) REFERENCES projects(id)
            \\)
        ;
        try self.base.db.db.exec(query, .{}, .{});
    }

    pub fn insert_task(self: *Self, task: Task) !i64 {
        const query =
            \\INSERT INTO tasks (title, description, status, project_id, due_date, created_at)
            \\VALUES (?, ?, ?, ?, ?, ?)
        ;
        var stmt = try self.base.db.db.prepare(query);
        defer stmt.deinit();

        try stmt.exec(.{}, .{
            task.title,
            task.description,
            @tagName(task.status),
            task.project_id,
            task.due_date,
            task.created_at,
        });

        return self.base.db.db.getLastInsertRowID();
    }

    pub fn find_by_id(self: *Self, id: i64) !?Task {
        const query = 
            \\SELECT id, title, description, status, project_id, due_date, created_at
            \\FROM tasks WHERE id = ?
        ;
        var stmt = try self.base.db.db.prepare(query);
        defer stmt.deinit();

        const row = try stmt.one(Task, .{id});
        return row;
    }

    pub fn find_by_project(self: *Self, project_id: i64) ![]Task {
        const query = 
            \\SELECT id, title, description, status, project_id, due_date, created_at
            \\FROM tasks WHERE project_id = ?
        ;
        var stmt = try self.base.db.db.prepare(query);
        defer stmt.deinit();

        return try stmt.all(Task, .{project_id});
    }

    pub fn update_status(self: *Self, task_id: i64, new_status: Task.TaskStatus) !void {
        const query = "UPDATE tasks SET status = ? WHERE id = ?";
        var stmt = try self.base.db.db.prepare(query);
        defer stmt.deinit();

        try stmt.exec(.{}, .{
            @tagName(new_status),
            task_id,
        });
    }

    pub fn delete_task(self: *Self, task_id: i64) !void {
        const query = "DELETE FROM tasks WHERE id = ?";
        var stmt = try self.base.db.db.prepare(query);
        defer stmt.deinit();

        try stmt.exec(.{}, .{task_id});
    }
}; 