const std = @import("std");
const vaxis = @import("vaxis");
const vxfw = vaxis.vxfw;
const Allocator = std.mem.Allocator;
const AppStyles = @import("../styles.zig");
const ShellterApp = @import("../shellter.zig");

const Panel = @import("../components/Panel.zig");
const ProjectsPanel = @import("../components/ProjectsPanel.zig");
const TaskList = @import("../components/TaskList.zig");

const Repository = @import("../domain/repository.zig").Repository;
const Database = @import("../domain/database.zig");

const ProjectRepository = @import("../domain/projects_repository.zig");

const TaskStatus = enum {
    open,
    in_progress,
    done,
};

pub const Task = struct {
    id: usize,
    description: []const u8,
    created_at: i64,
    due_date: ?i64,
    priority: enum { low, mediun, high },
    status: enum {
        open,
        in_progress,
        done,
    },

    pub fn uncomplete(self: *Task) void {
        self.status = .done;
    }

    pub fn complete(self: *Task) void {
        self.status = .open;
    }

    pub fn is_completed(self: *Task) bool {
        return self.status == .done;
    }

    pub fn status_label(self: *Task) []const u8 {
        switch (self.status) {
            .open => {
                return "Open";
            },
            .in_progress => {
                return "In Progress";
            },
            .done => {
                return "Done";
            },
        }
    }

    pub fn is_overdue(self: *Task) bool {
        if (self.due_date) |due| {
            const now = std.time.timestamp();
            return self.status != .done and now > due;
        }
        return false;
    }
};

pub const TaskManagerFocus = enum {
    groups,
    tasks,

    pub fn previous(self: TaskManagerFocus) TaskManagerFocus {
        return switch (self) {
            .groups => .tasks,
            .tasks => .groups,
        };
    }

    pub fn next(self: TaskManagerFocus) TaskManagerFocus {
        return switch (self) {
            .groups => .tasks,
            .tasks => .groups,
        };
    }

    pub fn label(self: TaskManagerFocus) []const u8 {
        return switch (self) {
            .groups => "groups",
            .tasks => "tasks",
        };
    }
};

pub const TaskManagerState = struct {
    projects: std.ArrayList(usize),
    tasks: std.ArrayList(Task),
    project_hover_idx: usize = 0,
    task_hover_idx: usize = 0,
};

const TaskManager = @This();

projects_panel: ProjectsPanel,
task_panel: TaskList,

userdata: ?*anyopaque = null,
state: ?*anyopaque = null,

focus: bool = false,
feature_focus: TaskManagerFocus = .groups,
feature_label: []const u8 = "groups",

repository: ProjectRepository,
allocator: std.mem.Allocator,

pub fn init(allocator: std.mem.Allocator, model: *anyopaque, db: *Database) !TaskManager {
    const state = try allocator.create(TaskManagerState);
    defer allocator.destroy(state);

    var repo = ProjectRepository.init(db);
    try repo.create_table();

    state.*.projects = std.ArrayList(usize).init(allocator);
    state.*.tasks = std.ArrayList(Task).init(allocator);

    const projects_panel: ProjectsPanel = ProjectsPanel.init(state, &repo);
    const task_panel: TaskList = TaskList.init(state);

    return .{
        .allocator = allocator,
        .userdata = model,
        .state = state,
        .repository = repo,
        .task_panel = task_panel,
        .projects_panel = projects_panel,
    };
}

pub fn deinit(_: *TaskManager) void {
    // self.allocator.destroy(self.state.?);
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
        .init => {
            try self.set_feature_focus(.groups, ctx);
            return ctx.consumeAndRedraw();
        },
        .key_press => |key| {
            if (key.matches('h', .{ .ctrl = false })) {
                self.feature_focus = self.feature_focus.previous();
                try self.set_feature_focus(self.feature_focus, ctx);
                ctx.consumeAndRedraw();
            }

            if (key.matches('l', .{ .ctrl = false })) {
                self.feature_focus = self.feature_focus.next();
                try self.set_feature_focus(self.feature_focus, ctx);
                ctx.consumeAndRedraw();
            }
        },
        .mouse => |mouse| {
            if (mouse.type == .press and mouse.button == .left) {
                try ctx.requestFocus(self.widget());
                ctx.consumeAndRedraw();
            }
        },
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

    var project_list_panel: Panel = .{ .child = self.projects_panel.widget(), .label = "grupos" };
    var task_panel: Panel = .{ .child = self.task_panel.widget(), .label = " tarefas" };

    const b1: vxfw.Border = .{ .child = project_list_panel.widget() };
    const projects_list_surface: vxfw.SubSurface = .{
        //origin
        .origin = .{ .row = 0, .col = 1 },
        .surface = try b1.draw(ctx.withConstraints(ctx.min, .{ .width = 30, .height = max.height - 1 })),
    };

    const b: vxfw.Border = .{ .child = task_panel.widget() };
    const task_panel_surface: vxfw.SubSurface = .{
        //origin
        .origin = .{ .row = 0, .col = 32 },
        .surface = try b.draw(ctx.withConstraints(ctx.min, .{ .width = max.width - 33, .height = max.height - 1 })),
    };

    //panel_names
    const groups_text: vxfw.Text = .{ .text = "Grupos", .style = .{ .reverse = self.feature_focus == .groups } };
    const tasks_text: vxfw.Text = .{ .text = "Tarefas", .style = .{ .reverse = self.feature_focus == .tasks } };

    const groups_name_surface: vxfw.SubSurface = .{
        .origin = .{ .row = 0, .col = 3 },
        .surface = try groups_text.draw(ctx.withConstraints(ctx.min, .{ .width = 30, .height = max.height - 1 })),
    };

    const task_name_surface: vxfw.SubSurface = .{
        .origin = .{ .row = 0, .col = 34 },
        .surface = try tasks_text.draw(ctx.withConstraints(ctx.min, .{ .width = max.width - 33, .height = max.height - 1 })),
    };

    const childs = try ctx.arena.alloc(vxfw.SubSurface, 4);
    childs[0] = projects_list_surface;
    childs[1] = task_panel_surface;
    childs[2] = groups_name_surface;
    childs[3] = task_name_surface;

    const surface = try vxfw.Surface.initWithChildren(
        ctx.arena,
        self.widget(),
        max,
        childs,
    );

    return surface;
}

pub fn set_feature_focus(self: *TaskManager, focus: TaskManagerFocus, ctx: *vxfw.EventContext) anyerror!void {
    self.feature_focus = focus;

    const model: *ShellterApp = @ptrCast(@alignCast(self.userdata));
    model.*.feature_child_focus_label = self.get_focus_label();

    switch (self.feature_focus) {
        .groups => {
            try ctx.requestFocus(self.projects_panel.widget());
        },
        .tasks => {
            try ctx.requestFocus(self.task_panel.widget());
        },
    }
}

pub fn get_focus_label(self: *TaskManager) []const u8 {
    switch (self.feature_focus) {
        .groups => {
            return "groups";
        },
        .tasks => {
            return "task_list";
        },
    }
}
