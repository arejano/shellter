const std = @import("std");

const vaxis = @import("vaxis");
const vxfw = vaxis.vxfw;

const FileTreeItem = @import("file_treee_item.zig");
const App = @import("App.zig");
const FileTree = @This();

const Center = vxfw.Center;
const styles = @import("styles.zig");
const ui_utils = @import("ui_utils.zig");

style: styles.StyleApp = styles.styles,

model: *App,
allocator: std.mem.Allocator,

// states
has_mouse: bool = false,
focused: bool = false,

//components
file_list: vxfw.ListView,
w_list: std.array_list.Managed(vxfw.Widget),

pub fn init(
    model: *App,
    allocator: std.mem.Allocator,
) FileTree {
    const w_list = std.array_list.Managed(vxfw.Widget).init(allocator);

    const list_view: vxfw.ListView = .{
        //
        .wheel_scroll = 1,
        .item_count = 1,
        .children = .{ .slice = w_list.items },
    };

    return .{
        //
        .model = model,
        .allocator = allocator,
        .file_list = list_view,
        .w_list = w_list,
    };
}

pub fn deinit(self: *FileTree) void {
    self.w_list.deinit();
}

pub fn widget(self: *FileTree) vxfw.Widget {
    return .{
        .userdata = self,
        .eventHandler = typeErasedEventHandler,
        .drawFn = typeErasedDrawFn,
    };
}

pub fn typeErasedEventHandler(ptr: *anyopaque, ctx: *vxfw.EventContext, event: vxfw.Event) anyerror!void {
    const self: *FileTree = @ptrCast(@alignCast(ptr));
    return handleEvent(self, ctx, event);
}

pub fn addWidget(self: *FileTree) std.mem.Allocator.Error!void {
    // const new_widget: vxfw.Text = .{ .text = "Gustavo" };

    var new_item = FileTreeItem.init(self.model);
    try self.w_list.append(new_item.widget());

    const new_count: ?u32 = @intCast(self.w_list.items.len);
    // std.debug.print("{any}", .{new_count});

    self.file_list.children = .{ .slice = self.w_list.items };
    self.file_list.item_count = @as(?u32, new_count);
}

pub fn handleEvent(self: *FileTree, ctx: *vxfw.EventContext, event: vxfw.Event) anyerror!void {
    switch (event) {
        .key_press => |key| {
            if (key.matches('n', .{})) {
                try self.addWidget();
                ctx.redraw = true;
            }

            if (key.matches('f', .{})) {
                try ctx.requestFocus(self.file_list.widget());
                ctx.redraw = true;
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
    const self: *FileTree = @ptrCast(@alignCast(ptr));
    return draw(self, ctx);
}

pub fn draw(self: *FileTree, ctx: vxfw.DrawContext) std.mem.Allocator.Error!vxfw.Surface {
    const style: vaxis.Style = if (self.has_mouse)
        self.style.has_mouse
    else
        self.style.default;

    const list_view: vxfw.SubSurface = .{
        .origin = .{ .row = 0, .col = 0 },
        .surface = try self.file_list.draw(ctx.withConstraints(ctx.min, .{ .width = (ctx.max.width orelse 0), .height = (ctx.max.height orelse 0) })),
    };

    const childs = try ctx.arena.alloc(vxfw.SubSurface, 2);
    childs[0] = try ui_utils.component_title("FileTree", ctx, 0, 0, (ctx.max.width orelse 0), 1, style);
    childs[1] = list_view;

    const surface = try vxfw.Surface.initWithChildren(
        ctx.arena,
        self.widget(),
        ctx.max.size(),
        childs,
    );
    return surface;
}
