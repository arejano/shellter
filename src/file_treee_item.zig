const std = @import("std");

const vaxis = @import("vaxis");
const vxfw = vaxis.vxfw;

const App = @import("App.zig");
const FileTreeItem = @This();

const styles = @import("styles.zig");
style: styles.StyleApp = styles.styles,

model: *App,

// states
has_mouse: bool = true,
focused: bool = false,

pub fn init(
    model: *App,
) FileTreeItem {
    return .{ .model = model };
}

pub fn widget(self: *FileTreeItem) vxfw.Widget {
    return .{
        .userdata = self,
        .eventHandler = typeErasedEventHandler,
        .drawFn = typeErasedDrawFn,
    };
}

pub fn typeErasedEventHandler(ptr: *anyopaque, ctx: *vxfw.EventContext, event: vxfw.Event) anyerror!void {
    const self: *FileTreeItem = @ptrCast(@alignCast(ptr));
    return handleEvent(self, ctx, event);
}

pub fn handleEvent(_: *FileTreeItem, _: *vxfw.EventContext, event: vxfw.Event) anyerror!void {
    switch (event) {
        .key_press => |_| {},
        .mouse => |_| {},
        .mouse_enter => {},
        .mouse_leave => {},
        .focus_in => {},
        .focus_out => {},
        else => {},
    }
}

pub fn typeErasedDrawFn(ptr: *anyopaque, ctx: vxfw.DrawContext) std.mem.Allocator.Error!vxfw.Surface {
    const self: *FileTreeItem = @ptrCast(@alignCast(ptr));
    return draw(self, ctx);
}

pub fn draw(self: *FileTreeItem, ctx: vxfw.DrawContext) std.mem.Allocator.Error!vxfw.Surface {
    const name: vxfw.Text = .{ .text = "file_tree_item" };

    const sized: vxfw.SizedBox = .{ .child = name.widget(), .size = .{ .width = (ctx.max.width orelse 0), .height = 1 } };

    const name_surface: vxfw.SubSurface = .{
        //
        .origin = .{ .row = 0, .col = 0 },
        .surface = try sized.widget().draw(ctx.withConstraints(ctx.min, .{ .width = ctx.max.width, .height = 1 })),
    };

    const childs = try ctx.arena.alloc(vxfw.SubSurface, 1);
    childs[0] = name_surface;

    @memset(name_surface.surface.buffer, .{ .style = styles.styles.default });

    const surface = try vxfw.Surface.initWithChildren(
        ctx.arena,
        self.widget(),
        ctx.max.size(),
        childs,
    );
    return surface;
}
