const std = @import("std");
const vaxis = @import("vaxis");
const vxfw = vaxis.vxfw;
const Allocator = std.mem.Allocator;
const AppStyles = @import("styles.zig");

const TopPanel = @import("components/top_menu.zig");
const LeftPanel = @import("components//left_panel.zig");
const RigthPanelComponent = @import("components/right_panel.zig");
const BottomPanelComponent = @import("components/bottom_panel.zig");

const TaskManager = @import("features/TaskManager.zig");
const FinanceManager = @import("features/FinanceManager.zig");
const ConfigManager = @import("features/ConfigManager.zig");

const Button = vxfw.Button;
const Text = vxfw.Text;
const Center = vxfw.Center;

const Panel = @import("components/Panel.zig");

pub const ProjectItemStruct = struct {
    active_tasks: usize,
    label: []const u8,
    selected: bool,
};

pub const Focus = enum {
    finance,
    task,
    config,

    pub fn next(self: Focus) Focus {
        return switch (self) {
            .finance => .task,
            .task => .config,
            .config => .finance,
        };
    }
};

const ShellterApp = @This();

app_name: []const u8 = "Shellter",
allocator: std.mem.Allocator,
version: []const u8 = "0.0.1",
vaxis_app: *vxfw.App,

top_panel: TopPanel,
task_manager: TaskManager,
finance_manager: FinanceManager,
config_manager: ConfigManager,
bottom_panel: BottomPanelComponent,

userdata: ?*anyopaque = null,
feature_focus: Focus = .task,

pub fn init(model: *ShellterApp, app: *vxfw.App, allocator: std.mem.Allocator) !ShellterApp {
    const vx_app: *vxfw.App = @ptrCast(@alignCast(app));

    const top_panel: TopPanel = TopPanel.init(model);
    const task_manager: TaskManager = try TaskManager.init(allocator);
    const finance_manager: FinanceManager = FinanceManager.init(allocator);
    const config_manager: ConfigManager = ConfigManager.init(allocator);

    return .{
        .userdata = model,
        .allocator = allocator,
        //
        .vaxis_app = vx_app,
        .top_panel = top_panel,
        .config_manager = config_manager,
        .task_manager = task_manager,
        .finance_manager = finance_manager,
        .bottom_panel = .{ .userdata = model },
    };
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
        .init => return ctx.requestFocus(self.widget()),
        .key_press => |key| {
            if (key.matches('c', .{ .ctrl = true })) {
                ctx.quit = true;
                return;
            }
        },
        .focus_in => return ctx.requestFocus(self.widget()),
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

    const top_menu_subsurface: vxfw.SubSurface = .{
        .origin = .{ .row = 0, .col = 0 },
        .surface = try self.top_panel.draw(ctx.withConstraints(ctx.min, .{ .width = max.width, .height = 1 })),
    };

    const task_manager_surface: vxfw.SubSurface = .{
        .origin = .{ .row = 1, .col = 0 },
        .surface = try self.task_manager.draw(ctx.withConstraints(ctx.min, .{ .width = max.width, .height = max.height })),
    };

    const finance_manager_surface: vxfw.SubSurface = .{
        .origin = .{ .row = 1, .col = 0 },
        .surface = try self.finance_manager.draw(ctx.withConstraints(ctx.min, .{ .width = max.width, .height = max.height })),
    };

    const config_manager_surface: vxfw.SubSurface = .{
        .origin = .{ .row = 1, .col = 0 },
        .surface = try self.config_manager.draw(ctx.withConstraints(ctx.min, .{ .width = max.width, .height = max.height })),
    };

    const bottom_surface: vxfw.SubSurface = .{
        .origin = .{ .row = max.height - 1, .col = 0 },
        .surface = try self.bottom_panel.draw(ctx.withConstraints(ctx.min, .{ .width = max.width, .height = 1 })),
    };

    // const text: vxfw.Text = .{
    //     .text = "Empty Panel",
    // };
    // const empty_center: vxfw.Center = .{
    //     .child = text.widget(),
    // };

    // const empty_surface: vxfw.SubSurface = .{
    //     .origin = .{ .row = 1, .col = 0 },
    //     .surface = try empty_center.draw(ctx.withConstraints(ctx.min, .{ .width = max.width, .height = max.height })),
    // };
    // _ = empty_surface;

    const childs = try ctx.arena.alloc(vxfw.SubSurface, 3);
    childs[0] = top_menu_subsurface;

    switch (self.feature_focus) {
        .task => {
            childs[1] = task_manager_surface;
        },
        .finance => {
            childs[1] = finance_manager_surface;
        },
        .config => {
            childs[1] = config_manager_surface;
        },
    }

    childs[2] = bottom_surface;

    const surface = try vxfw.Surface.initWithChildren(
        ctx.arena,
        self.widget(),
        max,
        childs,
    );
    @memset(surface.buffer, .{ .style = AppStyles.cat_background() });

    return surface;
}
