const std = @import("std");
const vaxis = @import("vaxis");
const vxfw = vaxis.vxfw;
const Allocator = std.mem.Allocator;
const AppStyles = @import("../styles.zig");
const ShellterApp = @import("../shellter.zig");

const Panel = @import("../components/Panel.zig");
const ProjectsPanel = @import("../components/ProjectsPanel.zig");
const TaskList = @import("../components/TaskList.zig");

pub const TaskManagerState = struct {
    projects: std.ArrayList(usize),
};

const TaskManager = @This();

// : Panel,
// right_panel: Panel,

projects_panel: ProjectsPanel,
task_panel: TaskList,

userdata: ?*anyopaque = null,

pub fn init(model: *anyopaque) TaskManager {
    const projects_panel: ProjectsPanel = ProjectsPanel.init(model);
    const task_panel: TaskList = TaskList.init(model);

    return .{ .userdata = model, .task_panel = task_panel, .projects_panel = projects_panel };
}

pub fn widget(self: *TaskManager) vxfw.Widget {
    return .{
        .userdata = self,
        .eventHandler = typeErasedEventHandler,
        .drawFn = typeErasedDrawFn,
    };
}

fn typeErasedEventHandler(ptr: *anyopaque, ctx: *vxfw.EventContext, event: vxfw.Event) anyerror!void {
    const self: *TaskManager = @ptrCast(@alignCast(ptr));
    return self.handleEvent(ctx, event);
}

fn typeErasedDrawFn(ptr: *anyopaque, ctx: vxfw.DrawContext) Allocator.Error!vxfw.Surface {
    const self: *TaskManager = @ptrCast(@alignCast(ptr));
    return self.draw(ctx);
}

pub fn handleEvent(self: *TaskManager, ctx: *vxfw.EventContext, event: vxfw.Event) anyerror!void {
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

pub fn draw(self: *TaskManager, ctx: vxfw.DrawContext) Allocator.Error!vxfw.Surface {
    const max = ctx.max.size();

    var project_list_panel: Panel = .{ .child = self.projects_panel.widget(), .label = " Projects" };

    var task_panel: Panel = .{ .child = self.task_panel.widget(), .label = " Tasks" };

    const projects_list_surface: vxfw.SubSurface = .{
        //origin
        .origin = .{ .row = 0, .col = 0 },
        .surface = try project_list_panel.draw(ctx.withConstraints(ctx.min, .{ .width = 30, .height = max.height - 2 })),
    };

    const task_panel_surface: vxfw.SubSurface = .{
        //origin
        .origin = .{ .row = 0, .col = 31 },
        .surface = try task_panel.draw(ctx.withConstraints(ctx.min, .{ .width = max.width - 30, .height = max.height - 2 })),
    };

    const childs = try ctx.arena.alloc(vxfw.SubSurface, 2);
    childs[0] = projects_list_surface;
    childs[1] = task_panel_surface;

    const surface = try vxfw.Surface.initWithChildren(
        ctx.arena,
        self.widget(),
        max,
        childs,
    );

    @memset(surface.buffer, .{ .style = AppStyles.cat_background() });
    return surface;
}
