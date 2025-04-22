const std = @import("std");
const vaxis = @import("vaxis");
const vxfw = vaxis.vxfw;
const Allocator = std.mem.Allocator;
const AppStyles = @import("../styles.zig");
const ProjectsList = @import("../components/ProjectsList.zig");
const ShellterApp = @import("../shellter.zig");

const ProjectsPanel = @This();

label: []const u8,

//State
mouse_down: bool = false,
has_mouse: bool = false,
has_focus: bool = false,

userdata: ?*anyopaque = null,

projects_list: ProjectsList,

pub fn init(model: *anyopaque) ProjectsPanel {
    const project_list: ProjectsList = ProjectsList.init(model);

    return .{
        .userdata = model,
        .label = "ProjectsList",
        .projects_list = project_list,
    };
}

fn newProject(maybe_ptr: ?*anyopaque, ctx: *vxfw.EventContext) anyerror!void {
    const ptr = maybe_ptr orelse return;
    const self: *ShellterApp = @ptrCast(@alignCast(ptr));
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

    const state: *ShellterApp = @ptrCast(@alignCast(self.userdata));

    const pj_list_surface: vxfw.SubSurface = .{
        .origin = .{ .row = 0, .col = 0 },
        .surface = try self.projects_list.draw(ctx.withConstraints(ctx.min, .{ .width = max.width, .height = max.height - 1 })),
    };

    const text_fmt = try std.fmt.allocPrint(ctx.arena, "{d}", .{state.projects.items.len});
    const pj_text: vxfw.Text = .{ .text = text_fmt };

    const childs = try ctx.arena.alloc(vxfw.SubSurface, 2);
    childs[0] = .{
        .origin = .{ .row = max.height - 10, .col = 0 },
        .surface = try pj_text.draw(ctx.withConstraints(ctx.min, .{ .width = max.width, .height = 1 })),
    };
    childs[1] = pj_list_surface;

    const surface = try vxfw.Surface.initWithChildren(
        ctx.arena,
        self.widget(),
        max,
        childs,
    );
    return surface;
}
