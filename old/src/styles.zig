const vaxis = @import("vaxis");

pub const StyleApp = struct {
    default: vaxis.Style,
    mouse_down: vaxis.Style,
    hover: vaxis.Style,
    focus: vaxis.Style,
    has_mouse: vaxis.Style,
};

pub const styles: StyleApp = .{
    .default = .{ .reverse = false },
    .mouse_down = .{ .fg = .{ .index = 4 }, .reverse = true },
    .hover = .{ .fg = .{ .index = 3 }, .reverse = true },
    .focus = .{ .fg = .{ .index = 5 }, .reverse = true },
    .has_mouse = .{ .reverse = true },
};
