const std = @import("std");
const sqlite = @import("sqlite");

const Database = @import("../domain/database.zig");
const BaseRepository = @import("../domain/repository.zig").Repository;

pub const Project = struct {
    id: i64,
    description: []const u8,
    details: []const u8,
    active_tasks: usize,
};

pub const ProjectRepository = @This();

base: BaseRepository(Project),

pub fn init(db: *Database) ProjectRepository {
    return .{ .base = BaseRepository(Project).init(db) };
}

pub fn create_table(self: *ProjectRepository) !void {
    const query = "CREATE TABLE IF NOT EXISTS projects(id integer primary key, name text, age integer, salary integer)";
    try self.base.db.db.exec(query, .{}, .{});
}

// Implemente os métodos específicos para User
pub fn createProject(self: *ProjectRepository) !void {
    // const new_pj: Project = .{ .id = 0, .description = "NovoProjeto", .details = "Details", .active_tasks = 0 };
    // const query = std.fmt.comptimePrint(
    //     "INSERT INTO projects(name, email) VALUES ('{s}', '{s}')",
    //     .{ new_pj.description, new_pj.details },
    // );
    // try self.base.db.db.exec(query, .{}, .{});

    const query = "CREATE TABLE IF NOT EXISTS projects(id integer primary key, name text, age integer, salary integer)";
    try self.base.db.db.exec(query, .{}, .{});
}

pub fn findUserById(repo: *ProjectRepository, id: i64) !?Project {
    const query = std.fmt.comptimePrint("SELECT * FROM users WHERE id = {d}", .{id});
    const users = try repo.db.query(Project, query);
    return if (users.len > 0) users[0] else null;
}
