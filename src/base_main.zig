const std = @import("std");

const vaxis = @import("vaxis");
const vxfw = vaxis.vxfw;

const ShellterApp = @import("shellter.zig");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();

    const allocator = gpa.allocator();

    var app = try vxfw.App.init(allocator);
    defer app.deinit();

    // Criar o ponteiro para a aplicacao
    const shellter_app = try allocator.create(ShellterApp);
    defer allocator.destroy(shellter_app);

    // Passar o valor inicial da aplicacao para o ponteiro (Memoria Reservada para o aplicativo)
    shellter_app.* = ShellterApp.init(shellter_app, &app, allocator);
    try app.run(shellter_app.widget(), .{});
}
