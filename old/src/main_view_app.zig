const std = @import("std");

const vaxis = @import("vaxis");
const vxfw = vaxis.vxfw;

const App = @import("App.zig");

const TopBar = @import("top_bar.zig");
const Editor = @import("editor.zig");
const StatusBar = @import("status_bar.zig");
const FileTree = @import("file_tree.zig");
const HelpComponent = @import("help.zig");

const MainViewApp = @This();

const ComponentItem = struct {
    status: ComponentStatus = .Inactive,
    widget: vxfw.Widget,

    pub fn init(w: vxfw.Widget, status: ComponentStatus) ComponentItem {
        return .{
            .widget = w,
            .status = status,
        };
    }
};

const ComponentStatus = enum {
    Active,
    Inactive,
};

component_list: std.array_list.Managed(ComponentItem),

model: *App,
allocator: std.mem.Allocator,

// base states
has_mouse: bool = false,
focused: bool = false,

pub fn init(
    model: *App,
    allocator: std.mem.Allocator,
) std.mem.Allocator.Error!MainViewApp {
    var component_list = std.array_list.Managed(ComponentItem).init(allocator);

    var top_bar = TopBar.init(model);
    var editor = Editor.init(model, allocator);
    var status_bar = StatusBar.init(model, allocator);
    var file_tree = FileTree.init(model, allocator);

    try component_list.append(.{ .widget = top_bar.widget(), .status = .Active });
    try component_list.append(.{ .widget = editor.widget(), .status = .Active });
    try component_list.append(.{ .widget = status_bar.widget(), .status = .Active });
    try component_list.append(.{ .widget = file_tree.widget(), .status = .Active });

    return .{ .model = model, .allocator = allocator, .component_list = component_list };
}

pub fn deinit(self: *MainViewApp) void {
    std.debug.print("\nDeinitMainView\n", .{});
    self.component_list.deinit();
}

pub fn widget(self: *MainViewApp) vxfw.Widget {
    return .{
        .userdata = self,
        .eventHandler = typeErasedEventHandler,
        .drawFn = typeErasedDrawFn,
    };
}

pub fn typeErasedEventHandler(ptr: *anyopaque, ctx: *vxfw.EventContext, event: vxfw.Event) anyerror!void {
    const self: *MainViewApp = @ptrCast(@alignCast(ptr));
    return handleEvent(self, ctx, event);
}

pub fn getInactiveComponents(self: *MainViewApp) std.mem.Allocator.Error!std.array_list.Managed(*const ComponentItem) {
    var temp = std.array_list.Managed(*const ComponentItem).init(self.allocator);

    self.component_list.items[0].status = .Inactive;
    self.component_list.items[1].status = .Inactive;

    for (self.component_list.items) |item| {
        if (item.status == .Inactive) {
            // std.debug.print("{any}", .{&item});
            temp.append(&item);
        }
    }

    return temp;
}

pub fn handleEvent(self: *MainViewApp, ctx: *vxfw.EventContext, event: vxfw.Event) anyerror!void {
    switch (event) {
        .key_press => |key| {
            if (key.matches('p', .{})) {
                std.debug.print("\nTestando\n", .{});

                const pointer_active_list = try self.getInactiveComponents();
                defer {
                    pointer_active_list.deinit();
                }

                // for (pointer_active_list) |pointer| {
                //     std.debug.print("{any}", .{pointer});
                // }

                return;
            }
        },
        .mouse => |_| {},
        .mouse_enter => {
            self.has_mouse = true;
            try ctx.setMouseShape(.pointer);
            return ctx.consumeAndRedraw();
        },
        .mouse_leave => {
            self.has_mouse = false;
            try ctx.setMouseShape(.default);
            return ctx.consumeAndRedraw();
        },
        .focus_in => {
            self.focused = true;
            ctx.redraw = true;
        },
        .focus_out => {
            self.focused = false;
            ctx.redraw = false;
        },
        else => {},
    }
}

pub fn typeErasedDrawFn(ptr: *anyopaque, ctx: vxfw.DrawContext) std.mem.Allocator.Error!vxfw.Surface {
    const self: *MainViewApp = @ptrCast(@alignCast(ptr));
    return draw(self, ctx);
}

pub fn draw(self: *MainViewApp, ctx: vxfw.DrawContext) std.mem.Allocator.Error!vxfw.Surface {
    const name: vxfw.Text = .{ .text = "MainViewApp" };
    const name_surface: vxfw.SubSurface = .{
        //
        .origin = .{ .row = 0, .col = 0 },
        .surface = try name.draw(ctx.withConstraints(ctx.min, .{ .width = ctx.max.width, .height = 1 })),
    };

    const childs = try ctx.arena.alloc(vxfw.SubSurface, 1);
    childs[0] = name_surface;

    const surface = try vxfw.Surface.initWithChildren(
        ctx.arena,
        self.widget(),
        ctx.max.size(),
        childs,
    );
    return surface;
}
