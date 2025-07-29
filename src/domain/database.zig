const sqlite = @import("sqlite");

pub const Database = @This();

db: sqlite.Db,

pub fn init(_: []const u8) !Database {
    const db = try sqlite.Db.init(.{
        .mode = sqlite.Db.Mode{ .File = "shellter_data.db" },
        .open_flags = .{
            .write = true,
            .create = true,
        },
        .threading_mode = .MultiThread,
    });

    return .{ .db = db };
}

pub fn database(self: *Database) sqlite.Db {
    return self.db;
}

// Executa uma query sem retorno (INSERT/UPDATE/DELETE)
// pub fn exec(self: *Database, query: []const u8) !void {
//     try self.db.exec(query, .{}, .{});
// }

// Executa uma query com retorno (SELECT)
pub fn query(self: *Database, comptime T: type, q: []const u8) ![]T {
    _ = self;
    _ = q;
    // Implemente a lógica de deserialização (ex.: usando `std.json` ou um ORM simples)
    // Retorna um array de T (ex.: []User)
    // @compileError("Implemente a lógica de query para o tipo " ++ @typeName(T));
}

// Fecha a conexão
pub fn deinit(self: *Database) void {
    self.db.deinit();
}
