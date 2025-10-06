const std = @import("std");
const sqlite = @import("sqlite");

const Repository = @This();

db: sqlite.Db,
allocator: std.mem.Allocator,

pub fn init(allocator: std.mem.Allocator) anyerror!Repository {
    const db = try sqlite.Db.init(.{
        .mode = sqlite.Db.Mode{ .File = "shellter_data.db" },
        .open_flags = .{
            .write = true,
            .create = true,
        },
        .threading_mode = .MultiThread,
    });

    return .{
        .allocator = allocator,
        .db = db,
    };
}

pub fn deinit(self: *Repository) void {
    self.db.deinit();
}

pub fn test_db(self: *Repository) !void {
    try self.db.exec("CREATE TABLE IF NOT EXISTS employees(id integer primary key, name text, age integer, salary integer)", .{}, .{});
    const query =
        \\SELECT id, name, age, salary FROM employees WHERE age > ? AND age < ?
    ;
    var stmt = try self.db.prepare(query);
    defer stmt.deinit();
}
