const std = @import("std");
const vaxis = @import("vaxis");
const vxfw = vaxis.vxfw;
const AppStyles = @import("styles.zig");

const Allocator = std.mem.Allocator;

const Center = vxfw.Center;
const Text = vxfw.Text;

const AppMenu = @This();

style: struct {
    default: vaxis.Style = .{ .reverse = true },
    mouse_down: vaxis.Style = .{ .fg = .{ .index = 4 }, .reverse = true },
    hover: vaxis.Style = .{ .fg = .{ .index = 3 }, .reverse = true },
    focus: vaxis.Style = .{ .fg = .{ .index = 5 }, .reverse = true },
} = .{},

pub fn init() AppMenu {
    return .{};
}

pub fn widget(self: *AppMenu) vxfw.Widget {
    return .{
        .userdata = self,
        .eventHandler = typeErasedEventHandler,
        .drawFn = typeErasedDrawFn,
    };
}

fn typeErasedEventHandler(ptr: *anyopaque, ctx: *vxfw.EventContext, event: vxfw.Event) anyerror!void {
    const self: *AppMenu = @ptrCast(@alignCast(ptr));
    return self.handleEvent(ctx, event);
}

pub fn handleEvent(_: *AppMenu, ctx: *vxfw.EventContext, event: vxfw.Event) anyerror!void {
    switch (event) {
        .key_press => |key| {
            if (key.matches(vaxis.Key.enter, .{}) or key.matches('j', .{ .ctrl = true })) {
                // return self.doClick(ctx);
            }
        },
        .mouse => |_| {
            // if (self.mouse_down and mouse.type == .release) {
            // self.mouse_down = false;
            // return self.doClick(ctx);
            // }
            // if (mouse.type == .press and mouse.button == .left) {
            // self.mouse_down = true;
            // return ctx.consumeAndRedraw();
            // }
            // return ctx.consumeEvent();
        },
        .mouse_enter => {
            // implicit redraw
            // self.has_mouse = true;
            // try ctx.setMouseShape(.pointer);
            // return ctx.consumeAndRedraw();
        },
        .mouse_leave => {
            // self.has_mouse = false;
            // self.mouse_down = false;
            // implicit redraw
            try ctx.setMouseShape(.default);
        },
        .focus_in => {
            // self.focused = true;
            // ctx.redraw = true;
        },
        .focus_out => {
            // self.focused = false;
            // ctx.redraw = true;
        },
        else => {},
    }
}

fn typeErasedDrawFn(ptr: *anyopaque, ctx: vxfw.DrawContext) Allocator.Error!vxfw.Surface {
    const self: *AppMenu = @ptrCast(@alignCast(ptr));
    return self.draw(ctx);
}

pub fn draw(self: *AppMenu, ctx: vxfw.DrawContext) Allocator.Error!vxfw.Surface {
    const text: Text = .{
        .style = self.style.hover,
        .text = "AppMenu",
        .text_align = .center,
    };
    const center: Center = .{ .child = text.widget() };
    const surf = try center.draw(ctx);

    const button_surf = try vxfw.Surface.initWithChildren(ctx.arena, self.widget(), surf.size, surf.children);

    @memset(button_surf.buffer, .{ .style = AppStyles.dark_background() });
    return button_surf;
}

fn doClick(self: *AppMenu, ctx: *vxfw.EventContext) anyerror!void {
    try self.onClick(self.userdata, ctx);
    ctx.consume_event = true;
}
