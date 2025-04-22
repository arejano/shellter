const std = @import("std");
const vaxis = @import("vaxis");
const vxfw = vaxis.vxfw;
const Allocator = std.mem.Allocator;
const AppStyles = @import("../styles.zig");

const Panel = @import("../components/Panel.zig");

const FinanceManager = @This();

userdata: ?*anyopaque,

pub fn init(model: *anyopaque) FinanceManager {
    return .{ .userdata = model };
}

pub fn widget(self: *FinanceManager) vxfw.Widget {
    return .{
        .userdata = self,
        .eventHandler = typeErasedEventHandler,
        .drawFn = typeErasedDrawFn,
    };
}

fn typeErasedEventHandler(ptr: *anyopaque, ctx: *vxfw.EventContext, event: vxfw.Event) anyerror!void {
    const self: *FinanceManager = @ptrCast(@alignCast(ptr));
    return self.handleEvent(ctx, event);
}

fn typeErasedDrawFn(ptr: *anyopaque, ctx: vxfw.DrawContext) Allocator.Error!vxfw.Surface {
    const self: *FinanceManager = @ptrCast(@alignCast(ptr));
    return self.draw(ctx);
}

pub fn handleEvent(self: *FinanceManager, ctx: *vxfw.EventContext, event: vxfw.Event) anyerror!void {
    _ = self;
    _ = ctx;
    switch (event) {
        .key_press => |_| {},
        .mouse => |_| {},
        .focus_in => {},
        .focus_out => {},
        .mouse_enter => {},
        .mouse_leave => {},
        else => {},
    }
}

pub fn draw(self: *FinanceManager, ctx: vxfw.DrawContext) Allocator.Error!vxfw.Surface {
    const max = ctx.max.size();

    const name: vxfw.Text = .{ .text = "Hue" };

    const childs = try ctx.arena.alloc(vxfw.SubSurface, 1);
    childs[0] = .{
        .origin = .{ .row = 0, .col = 0 },
        .surface = try name.draw(ctx.withConstraints(ctx.min, .{ .width = max.width, .height = 1 })),
    };

    const surface = try vxfw.Surface.initWithChildren(
        ctx.arena,
        self.widget(),
        max,
        childs,
    );

    @memset(surface.buffer, .{ .style = AppStyles.wezterm() });
    return surface;
}
