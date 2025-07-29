const std = @import("std");

const vaxis = @import("vaxis");
const vxfw = vaxis.vxfw;

// const ShellterApp = @import("shellter.zig");
// const ShellterState = ShellterApp.ShellterState;
const AppState = @import("app_state.zig");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();

    const allocator = gpa.allocator();

    var app = try vxfw.App.init(allocator);
    defer app.deinit();

    const model = try allocator.create(AppState);
    defer allocator.destroy(model);

    model.* = AppState.init(model, &app, allocator);
    defer model.*.deinit();
    try app.run(model.widget(), .{});
}
