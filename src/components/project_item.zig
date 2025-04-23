const std = @import("std");
const vaxis = @import("vaxis");
const vxfw = vaxis.vxfw;
const Allocator = std.mem.Allocator;
const AppStyles = @import("../styles.zig");
const ShellterApp = @import("../shellter.zig");
const ProjectItemStruct = ShellterApp.ProjectItemStruct;

const Self = @This();

label: []const u8,
info: []const u8,

//State
mouse_down: bool = false,
has_mouse: bool = false,
selected: bool = false,

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
            if (key.matches(57349, .{ .ctrl = false })) {
                // self.counter += 1;
                return;
            }
        },
        .mouse => |mouse| {
            if (self.has_mouse and mouse.type == .release) {
                self.has_mouse = false;
                return ctx.consumeAndRedraw();
            }

            if (mouse.type == .press and mouse.button == .left) {
                self.has_mouse = true;
                return ctx.consumeAndRedraw();
            }
        },
        .focus_in => {},
        .focus_out => {},
        .mouse_enter => {
            self.has_mouse = true;
            return ctx.consumeAndRedraw();
        },
        .mouse_leave => {
            self.has_mouse = true;
            return ctx.consumeAndRedraw();
        },

        else => {},
    }
}

pub fn draw(self: *Self, ctx: vxfw.DrawContext) Allocator.Error!vxfw.Surface {
    const max_size = ctx.max.size();

    const style: vaxis.Style = if (self.selected) AppStyles.cat_select() else .{};

    const label: vxfw.Text = .{ .text = self.label, .style = style };

    const label_surface: vxfw.SubSurface = .{
        //origin
        .origin = .{ .row = 0, .col = 0 },
        .surface = try label.draw(ctx.withConstraints(ctx.min, .{ .width = AppStyles.left_panel_size, .height = max_size.height })),
    };

    const info: vxfw.Text = .{
        .text = self.info,
        .style = style,
    };

    const info_surface: vxfw.SubSurface = .{
        //origin
        .origin = .{ .row = 1, .col = 0 },
        .surface = try info.draw(ctx.withConstraints(ctx.min, .{ .width = AppStyles.left_panel_size, .height = max_size.height })),
    };

    const childs = try ctx.arena.alloc(vxfw.SubSurface, 2);
    childs[0] = label_surface;
    childs[1] = info_surface;

    const surface = try vxfw.Surface.initWithChildren(
        ctx.arena,
        self.widget(),
        max_size,
        childs,
    );
    if (self.selected) {
        @memset(surface.buffer, .{ .style = AppStyles.cat_select() });
    }
    return surface;
}
