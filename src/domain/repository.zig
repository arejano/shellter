const std = @import("std");
const sqlite = @import("sqlite");

// repository.zig
const Database = @import("../domain/database.zig").Database;

pub fn Repository(comptime T: type) type {
    return struct {
        db: *Database,

        const Self = @This();

        pub fn init(db: *Database) Self {
            return .{ .db = db };
        }

        // Métodos genéricos (CRUD)
        pub fn create(self: *Self, entity: T) !void {
            _ = self;
            _ = entity;
            // @compileError("Implemente create() para " ++ @typeName(T));
        }

        // pub fn findById(self: *Self, id: i64) !?T {
        //     _ = self;
        //     _ = id;
        //     // @compileError("Implemente findById() para " ++ @typeName(T));
        // }

        pub fn update(self: *Self, entity: T) !void {
            _ = self;
            _ = entity;
            // @compileError("Implemente update() para " ++ @typeName(T));
        }

        // pub fn delete(self: *Self, id: i64) !void {
        //     _ = self;
        //     _ = id;
        //     // @compileError("Implemente delete() para " ++ @typeName(T));
        // }
    };
}

// const Repository(comptime T:type) = @This();

// pub fn init(allocator: std.mem.Allocator) anyerror!Repository {
//     const db = try sqlite.Db.init(.{
//         .mode = sqlite.Db.Mode{ .File = "shellter_data.db" },
//         .open_flags = .{
//             .write = true,
//             .create = true,
//         },
//         .threading_mode = .MultiThread,
//     });

//     return .{
//         .allocator = allocator,
//         .db = db,
//     };
// }

// pub fn deinit(self: *Repository) void {
//     self.db.deinit();
// }

// pub fn test_db(self: *Repository) !void {
//     try self.db.exec("CREATE TABLE IF NOT EXISTS employees(id integer primary key, name text, age integer, salary integer)", .{}, .{});
//     const query =
//         \\SELECT id, name, age, salary FROM employees WHERE age > ? AND age < ?
//     ;
//     var stmt = try self.db.prepare(query);
//     defer stmt.deinit();
// }
