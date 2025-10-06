const std = @import("std");
const vaxis = @import("vaxis");
const vxfw = vaxis.vxfw;
const Allocator = std.mem.Allocator;
const AppStyles = @import("../styles.zig");
const TaskManager = @import("../features//TaskManager.zig");
const TaskManagerState = TaskManager.TaskManagerState;
const Task = TaskManager.Task;

const TaskList = @This();

label: []const u8,

//State
mouse_down: bool = false,
has_mouse: bool = false,
has_focus: bool = false,

userdata: ?*anyopaque = null,

pub fn init(model: *anyopaque) TaskList {
    return .{ .userdata = model, .label = "Tarefinhas" };
}

pub fn widget(self: *TaskList) vxfw.Widget {
    return .{
        .userdata = self,
        .eventHandler = typeErasedEventHandler,
        .drawFn = typeErasedDrawFn,
    };
}

fn typeErasedEventHandler(ptr: *anyopaque, ctx: *vxfw.EventContext, event: vxfw.Event) anyerror!void {
    const self: *TaskList = @ptrCast(@alignCast(ptr));
    return self.handleEvent(ctx, event);
}

fn typeErasedDrawFn(ptr: *anyopaque, ctx: vxfw.DrawContext) Allocator.Error!vxfw.Surface {
    const self: *TaskList = @ptrCast(@alignCast(ptr));
    return self.draw(ctx);
}

pub fn handleEvent(self: *TaskList, ctx: *vxfw.EventContext, event: vxfw.Event) anyerror!void {
    switch (event) {
        .key_press => |key| {
            if (key.matches('a', .{ .ctrl = false })) {
                try self.add_task();
                return ctx.consumeAndRedraw();
            }
        },
        .mouse => |_| {},
        .focus_in => {},
        .focus_out => {},
        .mouse_enter => {},
        .mouse_leave => {},
        else => {},
    }
}

pub fn add_task(self: *TaskList) !void {
    const task: Task = .{ .id = 0, .description = "Nova Tarefa", .due_date = undefined, .created_at = std.time.timestamp(), .priority = .low, .status = .open };
    const state: *TaskManagerState = @ptrCast(@alignCast(self.userdata));
    try state.tasks.append(task);
}

pub fn draw(self: *TaskList, ctx: vxfw.DrawContext) Allocator.Error!vxfw.Surface {
    const max = ctx.max.size();

    const model: *TaskManagerState = @ptrCast(@alignCast(self.userdata));
    const label = try std.fmt.allocPrint(ctx.arena, "{s}:{d}", .{ self.label, model.tasks.items.len });

    const panel_name: vxfw.Text = .{ .text = label, .style = .{ .reverse = true } };

    const name_surface: vxfw.SubSurface = .{
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

    // @memset(surface.buffer, .{ .style = AppStyles.cat_background() });
    return surface;
}
