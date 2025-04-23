const std = @import("std");
const vaxis = @import("vaxis");
const vxfw = vaxis.vxfw;
const Allocator = std.mem.Allocator;
const AppStyles = @import("../styles.zig");

const Panel = @This();
const BorderThemes = vxfw.BorderThemes;

label: []const u8,
child: vxfw.Widget = undefined,

//State
mouse_down: bool = false,
has_mouse: bool = false,
has_focus: bool = false,

pub fn init(model: *Panel) Panel {
    _ = model;
}

pub fn widget(self: *Panel) vxfw.Widget {
    return .{
        .userdata = self,
        .eventHandler = typeErasedEventHandler,
        .drawFn = typeErasedDrawFn,
    };
}

fn typeErasedEventHandler(ptr: *anyopaque, ctx: *vxfw.EventContext, event: vxfw.Event) anyerror!void {
    const self: *Panel = @ptrCast(@alignCast(ptr));
    return self.handleEvent(ctx, event);
}

fn typeErasedDrawFn(ptr: *anyopaque, ctx: vxfw.DrawContext) Allocator.Error!vxfw.Surface {
    const self: *Panel = @ptrCast(@alignCast(ptr));
    return self.draw(ctx);
}

pub fn handleEvent(self: *Panel, ctx: *vxfw.EventContext, event: vxfw.Event) anyerror!void {
    switch (event) {
        .key_press => |_| {},
        .mouse => |_| {},
        .focus_in => {
            self.has_focus = true;
            return ctx.consumeAndRedraw();
        },
        .focus_out => {
            self.has_focus = false;
            return ctx.consumeAndRedraw();
        },
        .mouse_enter => {},
        .mouse_leave => {},
        else => {},
    }
}

pub fn draw(self: *Panel, ctx: vxfw.DrawContext) Allocator.Error!vxfw.Surface {
    const max_size = ctx.max.size();

    const slot_suface: vxfw.SubSurface = .{
        //origin
        .z_index = 1,
        .origin = .{ .row = 0, .col = 0 },
        .surface = try self.child.draw(ctx.withConstraints(ctx.min, .{ .width = max_size.width, .height = max_size.height })),
    };

    const childs = try ctx.arena.alloc(vxfw.SubSurface, 1);
    childs[0] = slot_suface;

    const surface = try vxfw.Surface.initWithChildren(
        ctx.arena,
        self.widget(),
        max_size,
        childs,
    );

    return surface;
}
