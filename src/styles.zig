const vaxis = @import("vaxis");
pub const style: struct {
    default: vaxis.Style = .{ .reverse = true },
    mouse_down: vaxis.Style = .{ .fg = .{ .index = 4 }, .reverse = true },
    hover: vaxis.Style = .{ .fg = .{ .index = 3 }, .reverse = true },
    focus: vaxis.Style = .{ .fg = .{ .index = 5 }, .reverse = true },
    border_focus: vaxis.Style = .{ .fg = .{ .index = 5 }, .reverse = false },
} = .{};
