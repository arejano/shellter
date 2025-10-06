const std = @import("std");
const vaxis = @import("vaxis");
const vxfw = vaxis.vxfw;
const Allocator = std.mem.Allocator;
const AppStyles = @import("../styles.zig");
const ProjectItem = @import("../components/project_item.zig");
const TaskManagerState = @import("../features//TaskManager.zig").TaskManagerState;

const ProjectsList = @This();

//State
mouse_down: bool = false,
has_mouse: bool = false,
has_focus: bool = false,

userdata: ?*anyopaque = null,

pub fn init(model: *anyopaque) ProjectsList {
    return .{
        .userdata = model,
    };
}

fn newProject(maybe_ptr: ?*anyopaque, ctx: *vxfw.EventContext) anyerror!void {
    const ptr = maybe_ptr orelse return;
    const self: *TaskManagerState = @ptrCast(@alignCast(ptr));
    // _ = self;
    try self.projects.append(12);
    return ctx.consumeAndRedraw();
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
    const state: *TaskManagerState = @ptrCast(@alignCast(self.userdata));

    const childs = try ctx.arena.alloc(vxfw.SubSurface, state.projects.items.len);

    for (state.projects.items, 0..) |_, idx| {
        const text = try std.fmt.allocPrint(ctx.arena, "Project:{d}", .{idx});
        const select_counter = try std.fmt.allocPrint(ctx.arena, "Info:{d}", .{state.project_hover_idx});
        var project_item: ProjectItem = .{ .label = text, .info = select_counter, .selected = idx == state.project_hover_idx };
        const sb: vxfw.SubSurface = .{ .origin = .{ .row = @intCast(idx * 2), .col = 0 }, .surface = try project_item.draw(ctx.withConstraints(ctx.min, .{ .width = max.width, .height = 2 })) };
        childs[idx] = sb;
    }

    const surface = try vxfw.Surface.initWithChildren(
        ctx.arena,
        self.widget(),
        max,
        childs,
    );

    return surface;
}
