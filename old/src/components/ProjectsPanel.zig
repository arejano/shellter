const std = @import("std");
const vaxis = @import("vaxis");
const vxfw = vaxis.vxfw;
const Allocator = std.mem.Allocator;
const AppStyles = @import("../styles.zig");
const ProjectsList = @import("../components/ProjectsList.zig");
const TaskManagerState = @import("../features//TaskManager.zig").TaskManagerState;

const ShellterApp = @import("../shellter.zig");
const ProjectRepository = @import("../domain/projects_repository.zig");

const ProjectsPanel = @This();

label: []const u8,

//State
mouse_down: bool = false,
has_mouse: bool = false,
has_focus: bool = false,

userdata: ?*anyopaque = null,
repo: *ProjectRepository,

projects_list: ProjectsList,
select_idx: usize = 0,

pub fn init(model: *anyopaque, repo: *ProjectRepository) ProjectsPanel {
    const project_list: ProjectsList = ProjectsList.init(model);

    return .{
        .repo = repo,
        .userdata = model,
        .label = "ProjectsList",
        .projects_list = project_list,
    };
}

pub fn hover_up(self: *ProjectsPanel) void {
    const model: *TaskManagerState = @ptrCast(@alignCast(self.userdata));
    const last_idx = model.projects.items.len - 1;

    if (self.select_idx == 0) {
        self.select_idx = last_idx;
        model.*.project_hover_idx = self.select_idx;
    } else {
        self.select_idx = self.select_idx - 1;
        model.*.project_hover_idx = self.select_idx;
    }
}

pub fn hover_down(self: *ProjectsPanel) void {
    const model: *TaskManagerState = @ptrCast(@alignCast(self.userdata));
    const new_idx = self.select_idx + 1;

    if (new_idx > model.projects.items.len - 1) {
        self.select_idx = 0;
        model.project_hover_idx = 0;
    } else {
        self.select_idx = new_idx;
        model.project_hover_idx = new_idx;
    }
}

pub fn widget(self: *ProjectsPanel) vxfw.Widget {
    return .{
        .userdata = self,
        .eventHandler = typeErasedEventHandler,
        .drawFn = typeErasedDrawFn,
    };
}

fn typeErasedEventHandler(ptr: *anyopaque, ctx: *vxfw.EventContext, event: vxfw.Event) anyerror!void {
    const self: *ProjectsPanel = @ptrCast(@alignCast(ptr));
    return self.handleEvent(ctx, event);
}

fn typeErasedDrawFn(ptr: *anyopaque, ctx: vxfw.DrawContext) Allocator.Error!vxfw.Surface {
    const self: *ProjectsPanel = @ptrCast(@alignCast(ptr));
    return self.draw(ctx);
}

pub fn handleEvent(self: *ProjectsPanel, ctx: *vxfw.EventContext, event: vxfw.Event) anyerror!void {
    switch (event) {
        .key_press => |key| {
            if (key.matches('a', .{ .ctrl = false })) {
                try self.add_project();
                return ctx.consumeAndRedraw();
            }

            if (key.matches('j', .{ .ctrl = false })) {
                self.hover_down();
                return ctx.consumeAndRedraw();
            }

            if (key.matches('k', .{ .ctrl = false })) {
                self.hover_up();
                return ctx.consumeAndRedraw();
            }
        },
        .mouse => |_| {},
        .focus_in => {
            // try ctx.requestFocus(self.projects_list.widget());
            self.has_focus = true;
            ctx.consumeAndRedraw();
        },
        .focus_out => {
            self.has_focus = false;
            ctx.consumeAndRedraw();
        },
        .mouse_enter => {},
        .mouse_leave => {},
        else => {},
    }
}

pub fn add_project(self: *ProjectsPanel) !void {
    try self.repo.*.createProject();
    const state: *TaskManagerState = @ptrCast(@alignCast(self.userdata));
    try state.projects.append(12);
}

pub fn draw(self: *ProjectsPanel, ctx: vxfw.DrawContext) Allocator.Error!vxfw.Surface {
    const max = ctx.max.size();
    // const state: *TaskManagerState = @ptrCast(@alignCast(self.userdata));

    const pj_list_surface: vxfw.SubSurface = .{
        .origin = .{ .row = 0, .col = 0 },
        .surface = try self.projects_list.draw(ctx.withConstraints(ctx.min, .{ .width = max.width, .height = max.height - 1 })),
    };

    const childs = try ctx.arena.alloc(vxfw.SubSurface, 1);
    childs[0] = pj_list_surface;

    const surface = try vxfw.Surface.initWithChildren(
        ctx.arena,
        self.widget(),
        max,
        childs,
    );
    return surface;
}
