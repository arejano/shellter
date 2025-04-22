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

pub const TaskManagerFocus = enum {
    groups,
    tasks,
    info,

    pub fn previous(self: TaskManagerFocus) TaskManagerFocus {
        return switch (self) {
            .groups => .info,
            .info => .tasks,
            .tasks => .groups,
        };
    }

    pub fn next(self: TaskManagerFocus) TaskManagerFocus {
        return switch (self) {
            .groups => .tasks,
            .tasks => .info,
            .info => .groups,
        };
    }

    pub fn label(self: TaskManagerFocus) []const u8 {
        return switch (self) {
            .groups => "groups",
            .tasks => "tasks",
            .info => "info",
        };
    }
};

const TaskManager = @This();

// : Panel,
// right_panel: Panel,

projects_panel: ProjectsPanel,
task_panel: TaskList,

userdata: ?*anyopaque = null,

focus: bool = false,
feature_focus: TaskManagerFocus = .groups,
feature_label: []const u8 = "groups",

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
    switch (event) {
        .key_press => |key| {
            if (key.matches('a', .{ .ctrl = false })) {
                self.focus = !self.focus;
                ctx.consumeAndRedraw();
            }

            if (key.matches('h', .{ .ctrl = false })) {
                self.feature_focus = self.feature_focus.previous();
                ctx.consumeAndRedraw();
            }

            if (key.matches('l', .{ .ctrl = false })) {
                self.feature_focus = self.feature_focus.next();
                ctx.consumeAndRedraw();
            }
        },
        .mouse => |_| {},
        .focus_in => {
            self.focus = true;
            try ctx.requestFocus(self.task_panel.widget());
        },
        .focus_out => {
            self.focus = false;
            ctx.consumeAndRedraw();
        },
        .mouse_enter => {},
        .mouse_leave => {},
        else => {},
    }
}

pub fn draw(self: *TaskManager, ctx: vxfw.DrawContext) Allocator.Error!vxfw.Surface {
    const max = ctx.max.size();

    var project_list_panel: Panel = .{ .child = self.projects_panel.widget(), .label = self.feature_focus.label() };
    var task_panel: Panel = .{ .child = self.task_panel.widget(), .label = " tarefas" };

    const projects_list_surface: vxfw.SubSurface = .{
        //origin
        .origin = .{ .row = 0, .col = 1 },
        .surface = try project_list_panel.draw(ctx.withConstraints(ctx.min, .{ .width = 30, .height = max.height - 2 })),
    };

    const task_panel_surface: vxfw.SubSurface = .{
        //origin
        .origin = .{ .row = 0, .col = 32 },
        .surface = try task_panel.draw(ctx.withConstraints(ctx.min, .{ .width = max.width - 33, .height = max.height - 2 })),
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

    if (self.focus) {
        @memset(surface.buffer, .{ .style = AppStyles.wezterm() });
    }
    return surface;
}
