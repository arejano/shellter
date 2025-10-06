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
    const max = ctx.max.size();
    const shellter_model: *ShellterApp = @ptrCast(@alignCast(self.userdata));
    const label: []const u8 = shellter_model.get_focus_label();

    //FeatureName
    const panel_name: vxfw.Text = .{
        .text = label,
        .style = AppStyles.status_title(),
    };

    //Feature_Focus_Child
    const feature_child_label = try std.fmt.allocPrint(ctx.arena, " {s} ->", .{shellter_model.feature_child_focus_label});
    const panel_focus_child_name: vxfw.Text = .{ .text = feature_child_label, .style = .{ .reverse = true } };

    const name_surface: vxfw.SubSurface = .{
        //origin
        .origin = .{ .row = 0, .col = 0 },
        .surface = try panel_name.draw(ctx.withConstraints(ctx.min, .{ .width = @intCast(label.len), .height = 1 })),
    };

    const focus_child_name_surface: vxfw.SubSurface = .{
        //origin
        .origin = .{ .row = 0, .col = @intCast(label.len - 1) },
        .surface = try panel_focus_child_name.draw(ctx.withConstraints(ctx.min, .{ .width = 10, .height = 1 })),
    };

    const childs = try ctx.arena.alloc(vxfw.SubSurface, 2);
    childs[0] = name_surface;
    childs[1] = focus_child_name_surface;

    const surface = try vxfw.Surface.initWithChildren(
        //alloc
        ctx.arena,
        self.widget(),
        // ms,
        max,
        childs,
    );
    // @memset(surface.buffer, .{ .style = AppStyles.dark_background() });
    return surface;
}
