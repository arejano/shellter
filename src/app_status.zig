const std = @import("std");
const vaxis = @import("vaxis");
const vxfw = vaxis.vxfw;
const AppStyles = @import("styles.zig");

const Allocator = std.mem.Allocator;

const Center = vxfw.Center;
const Text = vxfw.Text;

const AppStatus = @This();

style: struct {
    default: vaxis.Style = .{ .reverse = true },
    mouse_down: vaxis.Style = .{ .fg = .{ .index = 4 }, .reverse = true },
    hover: vaxis.Style = .{ .fg = .{ .index = 3 }, .reverse = true },
    focus: vaxis.Style = .{ .fg = .{ .index = 5 }, .reverse = true },
} = .{},

pub fn init() AppStatus {
    return .{};
}

pub fn widget(self: *AppStatus) vxfw.Widget {
    return .{
        .userdata = self,
        .eventHandler = typeErasedEventHandler,
        .drawFn = typeErasedDrawFn,
    };
}

fn typeErasedEventHandler(ptr: *anyopaque, ctx: *vxfw.EventContext, event: vxfw.Event) anyerror!void {
    const self: *AppStatus = @ptrCast(@alignCast(ptr));
    return self.handleEvent(ctx, event);
}

pub fn handleEvent(_: *AppStatus, _: *vxfw.EventContext, event: vxfw.Event) anyerror!void {
    switch (event) {
        .key_press => |key| {
            if (key.matches(vaxis.Key.enter, .{}) or key.matches('j', .{ .ctrl = true })) {}
        },
        .mouse => |_| {},
        .mouse_enter => {},
        .mouse_leave => {},
        .focus_in => {},
        .focus_out => {},
        else => {},
    }
}

fn typeErasedDrawFn(ptr: *anyopaque, ctx: vxfw.DrawContext) Allocator.Error!vxfw.Surface {
    const self: *AppStatus = @ptrCast(@alignCast(ptr));
    return self.draw(ctx);
}

pub fn draw(self: *AppStatus, ctx: vxfw.DrawContext) Allocator.Error!vxfw.Surface {
    const text: Text = .{
        .style = self.style.mouse_down,
        .text = "AppStatus",
        .text_align = .center,
    };
    const center: Center = .{ .child = text.widget() };
    const surf = try center.draw(ctx);

    const button_surf = try vxfw.Surface.initWithChildren(ctx.arena, self.widget(), surf.size, surf.children);

    @memset(button_surf.buffer, .{ .style = AppStyles.dark_background() });
    return button_surf;
}

fn doClick(self: *AppStatus, ctx: *vxfw.EventContext) anyerror!void {
    try self.onClick(self.userdata, ctx);
    ctx.consume_event = true;
}
