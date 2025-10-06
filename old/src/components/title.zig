const std = @import("std");
const vaxis = @import("vaxis");
const vxfw = vaxis.vxfw;
const Allocator = std.mem.Allocator;
const AppStyles = @import("../styles.zig");

const Self = @This();

label: []const u8,

//State
mouse_down: bool = false,
has_mouse: bool = false,

pub fn init(model: *Self) Self {
    _ = model;
}

pub fn widget(self: *Self) vxfw.Widget {
    return .{
        .userdata = self,
        .eventHandler = typeErasedEventHandler,
        .drawFn = typeErasedDrawFn,
    };
}

pub fn widget_surface(self: *Self, ctx: vxfw.DrawContext, size: vxfw.Size) vxfw.SubSurface {
    const hw_text_surface: vxfw.SubSurface = .{
        //origin
        .origin = .{ .row = 1, .col = 0 },
        .surface = try self.draw(ctx.withConstraints(ctx.min, .{ .width = size.width, .height = size.height })),
    };
    return hw_text_surface;
}

fn typeErasedEventHandler(ptr: *anyopaque, ctx: *vxfw.EventContext, event: vxfw.Event) anyerror!void {
    const self: *Self = @ptrCast(@alignCast(ptr));
    return self.handleEvent(ctx, event);
}

fn typeErasedDrawFn(ptr: *anyopaque, ctx: vxfw.DrawContext) Allocator.Error!vxfw.Surface {
    const self: *Self = @ptrCast(@alignCast(ptr));
    return self.draw(ctx);
}

pub fn handleEvent(self: *Self, ctx: *vxfw.EventContext, event: vxfw.Event) anyerror!void {
    switch (event) {
        .key_press => |key| {
            if (key.matches('a', .{ .ctrl = false })) {
                // self.counter += 1;
                return;
            }
        },
        .mouse => |mouse| {
            if (self.mouse_down and mouse.type == .release) {
                self.mouse_down = false;
                self.has_mouse = !self.has_mouse;
                return ctx.consumeAndRedraw();
            }
            if (mouse.type == .press and mouse.button == .left) {
                self.mouse_down = true;
                return ctx.consumeAndRedraw();
            }
        },
        .focus_in => return ctx.requestFocus(self.widget()),
        .focus_out => {},
        .mouse_enter => {
            // self.has_mouse = true;
        },
        .mouse_leave => {
            // self.has_mouse = false;
        },

        else => {},
    }
}

pub fn draw(self: *Self, ctx: vxfw.DrawContext) Allocator.Error!vxfw.Surface {
    const max_size = ctx.max.size();
    const width = max_size.width;
    const height = max_size.height;

    const style = if (self.has_mouse) AppStyles.panel_name_dark_active() else AppStyles.panel_name_dark();

    const panel_name: vxfw.Text = .{
        .text = self.label,
        .style = style,
    };

    const center: vxfw.Center = .{ .child = panel_name.widget() };

    const name_surface: vxfw.SubSurface = .{
        //origin
        .origin = .{ .row = 0, .col = 0 },
        .surface = try center.draw(ctx.withConstraints(ctx.min, .{ .width = width, .height = height })),
    };

    const childs = try ctx.arena.alloc(vxfw.SubSurface, 1);
    childs[0] = name_surface;

    const surface = try vxfw.Surface.initWithChildren(
        //alloc
        ctx.arena,
        self.widget(),
        // ms,
        max_size,
        childs,
    );
    @memset(surface.buffer, .{ .style = style });
    return surface;
}
