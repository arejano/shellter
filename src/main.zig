const std = @import("std");

const vaxis = @import("vaxis");
const vxfw = vaxis.vxfw;

const App = @import("App.zig");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer {
        _ = gpa.detectLeaks();
        _ = gpa.deinit();
    }

    const allocator = gpa.allocator();

    const model = try allocator.create(App);
    model.* = try App.init(model, allocator);

    var app = try vxfw.App.init(allocator);
    defer app.deinit();

    defer {
        model.*.deinit();
        allocator.destroy(model);
    }

    try app.run(model.widget(), .{});
}
