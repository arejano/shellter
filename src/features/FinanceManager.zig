const std = @import("std");
const vaxis = @import("vaxis");
const vxfw = vaxis.vxfw;
const Allocator = std.mem.Allocator;
const AppStyles = @import("../styles.zig");

const Panel = @import("../components/Panel.zig");
const ProjectsList = @import("../components/ProjectsList.zig");

const FinanceManager = @This();

// : Panel,
// right_panel: Panel,

projects_panel: ProjectsList,

pub fn init(allocator: std.mem.Allocator) FinanceManager {
    const projects_panel: ProjectsList = ProjectsList.init(allocator);

    return .{ .projects_panel = projects_panel };
}

pub fn widget(self: *FinanceManager) vxfw.Widget {
    return .{
        .userdata = self,
        .eventHandler = typeErasedEventHandler,
        .drawFn = typeErasedDrawFn,
    };
}

fn typeErasedEventHandler(ptr: *anyopaque, ctx: *vxfw.EventContext, event: vxfw.Event) anyerror!void {
    const self: *FinanceManager = @ptrCast(@alignCast(ptr));
    return self.handleEvent(ctx, event);
}

fn typeErasedDrawFn(ptr: *anyopaque, ctx: vxfw.DrawContext) Allocator.Error!vxfw.Surface {
    const self: *FinanceManager = @ptrCast(@alignCast(ptr));
    return self.draw(ctx);
}

pub fn handleEvent(self: *FinanceManager, ctx: *vxfw.EventContext, event: vxfw.Event) anyerror!void {
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

pub fn draw(self: *FinanceManager, ctx: vxfw.DrawContext) Allocator.Error!vxfw.Surface {
    const max = ctx.max.size();

    const panel_name: vxfw.Text = .{ .text = "FinanceManager", .style = .{ .reverse = true } };

    const center: vxfw.Center = .{
        .child = panel_name.widget(),
    };

    const name_surface: vxfw.SubSurface = .{
        //origin
        .origin = .{ .row = 0, .col = 0 },
        .surface = try center.draw(ctx.withConstraints(ctx.min, .{ .width = max.width, .height = 1 })),
    };

    var project_list_panel: Panel = .{ .child = self.projects_panel.widget(), .label = "Groups" };

    var task_panel: Panel = .{ .child = self.projects_panel.widget(), .label = "Transactions" };

    const projects_list_surface: vxfw.SubSurface = .{
        //origin
        .origin = .{ .row = 1, .col = 0 },
        .surface = try project_list_panel.draw(ctx.withConstraints(ctx.min, .{ .width = 30, .height = max.height - 3 })),
    };

    const task_panel_surface: vxfw.SubSurface = .{
        //origin
        .origin = .{ .row = 1, .col = 30 },
        .surface = try task_panel.draw(ctx.withConstraints(ctx.min, .{ .width = max.width - 30, .height = max.height - 3 })),
    };

    const childs = try ctx.arena.alloc(vxfw.SubSurface, 3);
    childs[0] = name_surface;
    childs[1] = projects_list_surface;
    childs[2] = task_panel_surface;

    const surface = try vxfw.Surface.initWithChildren(
        ctx.arena,
        self.widget(),
        max,
        childs,
    );

    @memset(surface.buffer, .{ .style = AppStyles.dark_background() });
    return surface;
}
