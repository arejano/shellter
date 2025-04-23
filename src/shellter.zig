const std = @import("std");
const vaxis = @import("vaxis");
const vxfw = vaxis.vxfw;
const Allocator = std.mem.Allocator;
const AppStyles = @import("styles.zig");

const BottomPanelComponent = @import("components/bottom_panel.zig");

const TaskManager = @import("features/TaskManager.zig");
const FinanceManager = @import("features/FinanceManager.zig");

const Repository = @import("repository.zig");

const Panel = @import("components/Panel.zig");

pub const Focus = enum {
    finance,
    task,

    pub fn next(self: Focus) Focus {
        return switch (self) {
            .finance => .task,
            .task => .finance,
        };
    }
};

const ShellterApp = @This();

app_name: []const u8 = "Shellter",
allocator: std.mem.Allocator,
version: []const u8 = "0.0.1",
vaxis_app: *vxfw.App,

task_manager: TaskManager,
finance_manager: FinanceManager,
bottom_panel: BottomPanelComponent,

userdata: ?*anyopaque = null,
feature_focus: Focus = .task,
feature_child_focus_label: []const u8 = "",

projects: std.ArrayList(usize),

pub fn init(model: *ShellterApp, app: *vxfw.App, allocator: std.mem.Allocator) !ShellterApp {
    const vx_app: *vxfw.App = @ptrCast(@alignCast(app));

    const repository = try allocator.create(Repository);
    defer allocator.destroy(repository);

    repository.* = try Repository.init(allocator);

    const task_manager: TaskManager = try TaskManager.init(allocator, model, repository);
    const finance_manager: FinanceManager = FinanceManager.init(model);

    return .{
        .userdata = model,
        .allocator = allocator,
        .projects = std.ArrayList(usize).init(allocator),
        .vaxis_app = vx_app,
        .task_manager = task_manager,
        .finance_manager = finance_manager,
        .bottom_panel = .{ .userdata = model },
    };
}

pub fn set_feature_focus(self: *ShellterApp, focus: Focus, ctx: *vxfw.EventContext) anyerror!void {
    self.feature_focus = focus;

    switch (self.feature_focus) {
        .finance => {
            try ctx.requestFocus(self.finance_manager.widget());
        },
        .task => {
            try ctx.requestFocus(self.task_manager.widget());
        },
    }
}

pub fn get_focus_label(self: *ShellterApp) []const u8 {
    switch (self.feature_focus) {
        .finance => {
            return " financeiro::";
        },
        .task => {
            return " tarefas -> ";
        },
    }
}

pub fn widget(self: *ShellterApp) vxfw.Widget {
    return .{
        .userdata = self,
        .eventHandler = typeErasedEventHandler,
        .drawFn = typeErasedDrawFn,
    };
}

fn typeErasedEventHandler(ptr: *anyopaque, ctx: *vxfw.EventContext, event: vxfw.Event) anyerror!void {
    const self: *ShellterApp = @ptrCast(@alignCast(ptr));
    return self.handleEvent(ctx, event);
}

fn typeErasedDrawFn(ptr: *anyopaque, ctx: vxfw.DrawContext) Allocator.Error!vxfw.Surface {
    const self: *ShellterApp = @ptrCast(@alignCast(ptr));
    return self.draw(ctx);
}

pub fn handleEvent(self: *ShellterApp, ctx: *vxfw.EventContext, event: vxfw.Event) anyerror!void {
    switch (event) {
        .init => return ctx.requestFocus(self.task_manager.widget()),
        .key_press => |key| {
            if (key.matches('c', .{ .ctrl = true })) {
                ctx.quit = true;
                return;
            }
        },
        .focus_in => {
            return ctx.requestFocus(self.task_manager.widget());
        },
        else => {},
    }
}

fn onClick(maybe_ptr: ?*anyopaque, ctx: *vxfw.EventContext) anyerror!void {
    const ptr = maybe_ptr orelse return;
    const self: *ShellterApp = @ptrCast(@alignCast(ptr));
    self.counter +|= 1;
    return ctx.consumeAndRedraw();
}

pub fn draw(self: *ShellterApp, ctx: vxfw.DrawContext) Allocator.Error!vxfw.Surface {
    const max = ctx.max.size();

    const task_manager_surface: vxfw.SubSurface = .{
        .origin = .{ .row = 0, .col = 0 },
        .surface = try self.task_manager.draw(ctx.withConstraints(ctx.min, .{ .width = max.width, .height = max.height })),
    };

    const finance_manager_surface: vxfw.SubSurface = .{
        .origin = .{ .row = 0, .col = 0 },
        .surface = try self.finance_manager.draw(ctx.withConstraints(ctx.min, .{ .width = max.width, .height = max.height })),
    };

    const bottom_surface: vxfw.SubSurface = .{
        .origin = .{ .row = max.height - 1, .col = 0 },
        .surface = try self.bottom_panel.draw(ctx.withConstraints(ctx.min, .{ .width = max.width, .height = 1 })),
    };

    const childs = try ctx.arena.alloc(vxfw.SubSurface, 2);

    switch (self.feature_focus) {
        .task => {
            childs[0] = task_manager_surface;
        },
        .finance => {
            childs[0] = finance_manager_surface;
        },
    }

    childs[1] = bottom_surface;

    const surface = try vxfw.Surface.initWithChildren(
        ctx.arena,
        self.widget(),
        max,
        childs,
    );

    return surface;
}
