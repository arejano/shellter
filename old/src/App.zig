const std = @import("std");

const vaxis = @import("vaxis");
const vxfw = vaxis.vxfw;

const TopBar = @import("top_bar.zig");
const Editor = @import("editor.zig");
const StatusBar = @import("status_bar.zig");
const FileTree = @import("file_tree.zig");
const HelpComponent = @import("help.zig");

const MainAppView = @import("main_view_app.zig");

const App = @This();

const Focus = enum {
    Help,
    App,
    TopBar,
    FileTree,
    Editor,
    StatusBar,
};

model: *App,
allocator: std.mem.Allocator,
focused_component: Focus = .App,
focused_label: []u8,
len: usize = 0,

// components
main_view: MainAppView,
qt_active_components: usize = 0,
// top_bar: TopBar,
// editor: Editor,
// status_bar: StatusBar,
// file_tree: FileTree,
// help: HelpComponent,

//terminal
// terminal: vaxis.widgets.Terminal,

// states
has_mouse: bool = false,
focused: bool = false,

pub fn init(
    model: *App,
    allocator: std.mem.Allocator,
) std.mem.Allocator.Error!App {
    // const top_bar = TopBar.init(model);
    // const editor = Editor.init(model, allocator);
    // const status_bar = StatusBar.init(model, allocator);
    // const file_tree = FileTree.init(model, allocator);

    const main_view = try MainAppView.init(model, allocator);

    return .{
        //
        .model = model,
        .allocator = allocator,
        .main_view = main_view,
        // .top_bar = top_bar,
        // .editor = editor,
        // .status_bar = status_bar,
        // .file_tree = file_tree,
        .focused_label = &[_]u8{},
        // .help = HelpComponent.init(model),
    };
}

pub fn deinit(self: *App) void {
    self.main_view.deinit();
    // self.file_tree.deinit();
    // self.top_bar.deinit();
    self.allocator.free(self.focused_label);
}

pub fn widget(self: *App) vxfw.Widget {
    return .{
        .userdata = self,
        .eventHandler = typeErasedEventHandler,
        .drawFn = typeErasedDrawFn,
    };
}

pub fn typeErasedEventHandler(ptr: *anyopaque, ctx: *vxfw.EventContext, event: vxfw.Event) anyerror!void {
    const self: *App = @ptrCast(@alignCast(ptr));
    return handleEvent(self, ctx, event);
}

pub fn set_panel_focus(self: *App, focus: Focus, ctx: *vxfw.EventContext) anyerror!void {
    self.focused_component = focus;

    switch (self.focused_component) {
        .App => {},
        // .Editor => try ctx.requestFocus(self.editor.widget()),
        // .FileTree => try ctx.requestFocus(self.file_tree.widget()),
        // .StatusBar => try ctx.requestFocus(self.status_bar.widget()),
        .Help => {},
        else => {},
    }
    try self.update_focus_label();

    ctx.redraw = true;
}

pub fn handleEvent(self: *App, ctx: *vxfw.EventContext, event: vxfw.Event) anyerror!void {
    switch (event) {
        .init => |_| {
            std.debug.print("Iniciando o app", .{});
            try ctx.requestFocus(self.main_view.widget());
            ctx.redraw = true;
        },
        .key_press => |key| {
            if (key.matches('c', .{ .ctrl = true })) {
                ctx.quit = true;
                return;
            }

            const focus: Focus = if (key.matches(vaxis.Key.f1, .{})) .Help
                //
                else if (key.matches(vaxis.Key.f2, .{})) .FileTree
                //
                else if (key.matches(vaxis.Key.f3, .{})) .Editor
                //
                else .App;

            try self.set_panel_focus(focus, ctx);
        },
        .mouse => |_| {},
        .mouse_enter => {
            // self.has_mouse = true;
            // try ctx.setMouseShape(.pointer);
            // return ctx.consumeAndRedraw();
        },
        .mouse_leave => {
            // self.has_mouse = false;
            // try ctx.setMouseShape(.default);
            // return ctx.consumeAndRedraw();
        },
        .focus_in => {
            // self.focused = true;
            // ctx.redraw = true;
        },
        .focus_out => {
            // self.focused = false;
            // ctx.redraw = false;
        },
        else => {},
    }
}

pub fn typeErasedDrawFn(ptr: *anyopaque, ctx: vxfw.DrawContext) std.mem.Allocator.Error!vxfw.Surface {
    const self: *App = @ptrCast(@alignCast(ptr));
    return draw(self, ctx);
}

pub fn draw(self: *App, ctx: vxfw.DrawContext) std.mem.Allocator.Error!vxfw.Surface {
    //top_bar
    // const top_bar: vxfw.SubSurface = .{
    //     //
    //     .origin = .{ .row = 0, .col = 0 },
    //     .surface = try self.top_bar.draw(ctx.withConstraints(ctx.min, .{ .width = ctx.max.width, .height = 1 })),
    // };

    //file_tree
    // const file_tree: vxfw.SubSurface = .{
    //     //
    //     .origin = .{ .row = 1, .col = 0 },
    //     .surface = try self.file_tree.draw(ctx.withConstraints(ctx.min, .{ .width = 30, .height = (ctx.max.height orelse 0) - 2 })),
    // };
    // editor
    // const editor: vxfw.SubSurface = .{
    //     //
    //     .origin = .{ .row = 1, .col = 31 },
    //     .surface = try self.editor.draw(ctx.withConstraints(ctx.min, .{ .width = (ctx.max.width orelse 0) - 31, .height = (ctx.max.height orelse 0) - 2 })),
    // };
    // status
    // const status: vxfw.SubSurface = .{
    //     //
    //     .origin = .{ .row = (ctx.max.height orelse 0) - 1, .col = 0 },
    //     .surface = try self.status_bar.draw(ctx.withConstraints(ctx.min, .{ .width = ctx.max.width, .height = 1 })),
    // };

    // main_view
    const main_view: vxfw.SubSurface = .{
        //
        .origin = .{ .row = (ctx.max.height orelse 0) - 1, .col = 0 },
        .surface = try self.main_view.draw(ctx.withConstraints(ctx.min, .{ .width = ctx.max.width, .height = 1 })),
    };

    const childs = try ctx.arena.alloc(vxfw.SubSurface, 1);
    childs[0] = main_view;
    // childs[0] = top_bar;
    // childs[1] = file_tree;
    // childs[2] = editor;
    // childs[3] = status;

    const surface = try vxfw.Surface.initWithChildren(
        ctx.arena,
        self.widget(),
        ctx.max.size(),
        childs,
    );
    return surface;
}

pub fn update_focus_label(self: *App) std.mem.Allocator.Error!void {
    const focus_label = switch (self.focused_component) {
        .App => "App",
        .Editor => "Editor",
        .FileTree => "FileTree",
        .TopBar => "TopBar",
        .StatusBar => "StatusBar",
        .Help => "Help",
    };
    self.allocator.free(self.focused_label);

    const label = try std.fmt.allocPrint(self.allocator, "{s}: {s}", .{ "Focus", focus_label });
    defer {
        self.allocator.free(label);
    }

    self.focused_label = try self.allocator.alloc(u8, label.len);
    @memcpy(self.focused_label, label);
}
