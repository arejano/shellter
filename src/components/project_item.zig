const std = @import("std");
const vaxis = @import("vaxis");
const vxfw = vaxis.vxfw;
const Allocator = std.mem.Allocator;
const AppStyles = @import("../styles.zig");
const ShellterApp = @import("../shellter.zig");
const ProjectItemStruct = ShellterApp.ProjectItemStruct;

const Self = @This();

project_item: ProjectItemStruct,

//State
mouse_down: bool = false,
has_mouse: bool = false,

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

    const counter_label = try std.fmt.allocPrint(ctx.arena, " {d} | ", .{self.project_item.active_tasks});
    const counter_label_counter = if (counter_label.len > 0) counter_label.len else 0;

    const counter_text: vxfw.Text = .{
        .text = counter_label,
        .style = if (!self.project_item.selected) AppStyles.panel_name_light() else AppStyles.redBg(),
    };

    const counter_surface: vxfw.SubSurface = .{
        //origin
        .origin = .{ .row = 0, .col = 0 },
        .surface = try counter_text.draw(ctx.withConstraints(ctx.min, .{ .width = @intCast(counter_label_counter), .height = max_size.height })),
    };

    const project_name_text: vxfw.Text = .{
        .text = self.project_item.label,
        .style = .{ .reverse = self.has_mouse },
    };

    const project_name_surface: vxfw.SubSurface = .{
        //origin
        .origin = .{ .col = @intCast(counter_label_counter - 1), .row = 0 },
        .surface = try project_name_text.draw(ctx.withConstraints(ctx.min, .{ .width = max_size.width, .height = max_size.height })),
    };

    const childs = try ctx.arena.alloc(vxfw.SubSurface, 2);
    childs[0] = counter_surface;
    childs[1] = project_name_surface;

    const surface = try vxfw.Surface.initWithChildren(
        ctx.arena,
        self.widget(),
        max_size,
        childs,
    );
    return surface;
}
