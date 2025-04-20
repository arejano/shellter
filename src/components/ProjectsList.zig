const std = @import("std");
const vaxis = @import("vaxis");
const vxfw = vaxis.vxfw;
const Allocator = std.mem.Allocator;
const AppStyles = @import("../styles.zig");

const ProjectsList = @This();

label: []const u8,

//State
mouse_down: bool = false,
has_mouse: bool = false,
has_focus: bool = false,

pub fn init(allocator: std.mem.Allocator) ProjectsList {
    _ = allocator;

    return .{ .label = "ProjectsList" };
}

pub fn widget(self: *ProjectsList) vxfw.Widget {
    return .{
        .userdata = self,
        .eventHandler = typeErasedEventHandler,
        .drawFn = typeErasedDrawFn,
    };
}

fn typeErasedEventHandler(ptr: *anyopaque, ctx: *vxfw.EventContext, event: vxfw.Event) anyerror!void {
    const self: *ProjectsList = @ptrCast(@alignCast(ptr));
    return self.handleEvent(ctx, event);
}

fn typeErasedDrawFn(ptr: *anyopaque, ctx: vxfw.DrawContext) Allocator.Error!vxfw.Surface {
    const self: *ProjectsList = @ptrCast(@alignCast(ptr));
    return self.draw(ctx);
}

pub fn handleEvent(self: *ProjectsList, ctx: *vxfw.EventContext, event: vxfw.Event) anyerror!void {
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

pub fn draw(self: *ProjectsList, ctx: vxfw.DrawContext) Allocator.Error!vxfw.Surface {
    const max = ctx.max.size();

    const panel_name: vxfw.Text = .{ .text = self.label, .style = .{ .reverse = true } };

    const name_surface: vxfw.SubSurface = .{
        //origin
        .origin = .{ .row = 0, .col = 0 },
        .surface = try panel_name.draw(ctx.withConstraints(ctx.min, .{ .width = max.width, .height = max.height })),
    };

    const childs = try ctx.arena.alloc(vxfw.SubSurface, 1);
    childs[0] = name_surface;

    const surface = try vxfw.Surface.initWithChildren(
        ctx.arena,
        self.widget(),
        max,
        childs,
    );

    // const style = if (self.has_focus) AppStyles.redBg() else AppStyles.dark_background();
    // @memset(surface.buffer, .{ .style = style });
    return surface;
}
