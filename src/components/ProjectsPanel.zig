const std = @import("std");
const vaxis = @import("vaxis");
const vxfw = vaxis.vxfw;
const Allocator = std.mem.Allocator;
const AppStyles = @import("../styles.zig");
const TaskManagerState = @import("../features/TaskManager.zig").TaskManagerState;
const ProjectsList = @import("../components/ProjectsList.zig");

const ProjectsPanel = @This();

label: []const u8,

//State
mouse_down: bool = false,
has_mouse: bool = false,
has_focus: bool = false,

button: vxfw.Button,
state: ?*anyopaque = null,

projects_list: ProjectsList,

pub fn init(allocator: std.mem.Allocator, state: *anyopaque) ProjectsPanel {
    const project_list: ProjectsList = ProjectsList.init(allocator, state);

    return .{
        .state = state,
        .label = "ProjectsList",
        .projects_list = project_list,
        .button = .{
            .userdata = state,
            .label = "Novo Projeto",
            .onClick = ProjectsPanel.newProject,
        },
    };
}

fn newProject(maybe_ptr: ?*anyopaque, ctx: *vxfw.EventContext) anyerror!void {
    const ptr = maybe_ptr orelse return;
    const self: *TaskManagerState = @ptrCast(@alignCast(ptr));
    // _ = self;
    try self.projects.append(12);
    return ctx.consumeAndRedraw();
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

pub fn draw(self: *ProjectsPanel, ctx: vxfw.DrawContext) Allocator.Error!vxfw.Surface {
    const max = ctx.max.size();

    const button_surface: vxfw.SubSurface = .{
        .origin = .{ .row = max.height - 2, .col = 0 },
        .surface = try self.button.draw(ctx.withConstraints(ctx.min, .{ .width = max.width, .height = 1 })),
    };

    const state: *TaskManagerState = @ptrCast(@alignCast(self.state));

    const pj_list_surface: vxfw.SubSurface = .{
        .origin = .{ .row = 0, .col = 0 },
        .surface = try self.projects_list.draw(ctx.withConstraints(ctx.min, .{ .width = max.width, .height = max.height - 2 })),
    };

    const text_fmt = try std.fmt.allocPrint(ctx.arena, "{d}", .{state.projects.items.len});
    const pj_text: vxfw.Text = .{ .text = text_fmt };

    const childs = try ctx.arena.alloc(vxfw.SubSurface, 3);
    childs[0] = button_surface;
    childs[1] = .{
        .origin = .{ .row = max.height - 10, .col = 0 },
        .surface = try pj_text.draw(ctx.withConstraints(ctx.min, .{ .width = max.width, .height = 1 })),
    };
    childs[2] = pj_list_surface;

    const surface = try vxfw.Surface.initWithChildren(
        ctx.arena,
        self.widget(),
        max,
        childs,
    );

    @memset(surface.buffer, .{ .style = AppStyles.cat_panel2_background() });
    return surface;
}
