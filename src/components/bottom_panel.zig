const std = @import("std");
const vaxis = @import("vaxis");
const vxfw = vaxis.vxfw;
const Allocator = std.mem.Allocator;
const AppStyles = @import("../styles.zig");
const ShellterApp = @import("../shellter.zig");

const Self = @This();

userdata: ?*anyopaque = null,

pub fn widget(self: *Self) vxfw.Widget {
    return .{
        .userdata = self,
        .eventHandler = typeErasedEventHandler,
        .drawFn = typeErasedDrawFn,
    };
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
            _ = key;
        },
        .mouse => |mouse| {
            _ = mouse;
        },
        .focus_in => return ctx.requestFocus(self.widget()),
        .focus_out => {},
        .mouse_enter => {},
        .mouse_leave => {},

        else => {},
    }
}

pub fn draw(self: *Self, ctx: vxfw.DrawContext) Allocator.Error!vxfw.Surface {
    const model: *ShellterApp = @ptrCast(@alignCast(self.userdata));

    const focus = if (model.component_focus == .LeftPanel) "Left" else "Right";
    const max = ctx.max.size();

    const log_text = "LOG:";

    //Title
    const panel_name: vxfw.Text = .{
        .text = log_text,
        .style = AppStyles.status_title(),
    };

    const name_surface: vxfw.SubSurface = .{
        //origin
        .origin = .{ .row = 0, .col = 0 },
        .surface = try panel_name.draw(ctx.withConstraints(ctx.min, .{ .width = @intCast(log_text.len), .height = 1 })),
    };

    //Spliter
    // const spliter_text = ":";
    const splitter: vxfw.Text = .{
        .text = focus,
        // .style = AppStyles.redBg(),
        .style = .{ .reverse = true },
    };

    const spliter_surface: vxfw.SubSurface = .{
        .origin = .{ .row = 0, .col = @intCast(log_text.len) },
        .surface = try splitter.draw(ctx.withConstraints(ctx.min, .{ .width = @intCast(focus.len), .height = 1 })),
    };

    const childs = try ctx.arena.alloc(vxfw.SubSurface, 2);
    childs[0] = name_surface;
    childs[1] = spliter_surface;

    const surface = try vxfw.Surface.initWithChildren(
        //alloc
        ctx.arena,
        self.widget(),
        // ms,
        max,
        childs,
    );
    @memset(surface.buffer, .{ .style = AppStyles.dark_background() });
    return surface;
}
