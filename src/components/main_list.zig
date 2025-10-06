const std = @import("std");
const vaxis = @import("vaxis");
const vxfw = vaxis.vxfw;

const App = @import("../App.zig");
const Self = @This();

model: *App,
allocator: std.mem.Allocator,

focused: bool = false,

list_view: vxfw.ListView,
filtered: std.array_list.Managed(vxfw.Text),

pub fn init(model: *App, allocator: std.mem.Allocator) !Self {
    return .{
        //
        .model = model,
        .allocator = allocator,
        .filtered = std.array_list.Managed(vxfw.Text).init(allocator),
        .list_view = .{ .children = .{ .builder = .{
            .userdata = model,
            .buildFn = Self.widgetBuilder,
        } } },
    };
}

pub fn deinit(self: *Self) void {
    self.filtered.deinit();
}

pub fn widgetBuilder(opq: *const anyopaque, idx: usize, _: usize) ?vxfw.Widget {
    const self: *const Self = @ptrCast(@alignCast(opq));
    _ = idx;
    _ = self;
    return null;
}

pub fn widget(self: *Self) vxfw.Widget {
    return .{
        .userdata = self,
        .eventHandler = eventFn,
        .drawFn = drawFn,
    };
}

pub fn eventFn(
    //
    opq: *anyopaque,
    ctx: *vxfw.EventContext,
    event: vxfw.Event,
) anyerror!void {
    const self: *Self = @ptrCast(@alignCast(opq));
    return handleEvent(self, ctx, event);
}

pub fn handleEvent(
    self: *Self,
    ctx: *vxfw.EventContext,
    event: vxfw.Event,
) anyerror!void {
    // _ = self;
    // _ = ctx;
    switch (event) {
        .key_press => |_| {},
        .mouse => |mouse| {
            if (mouse.button == .left and mouse.type == .press) {
                try ctx.requestFocus(self.widget());
            }
        },
        .mouse_enter => {},
        .mouse_leave => {},
        .focus_in => {
            self.focused = true;
            ctx.redraw = true;
        },
        .focus_out => {
            self.focused = false;
            ctx.redraw = true;
        },
        else => {},
    }
}

pub fn drawFn(
    opq: *anyopaque,
    ctx: vxfw.DrawContext,
) std.mem.Allocator.Error!vxfw.Surface {
    const self: *Self = @ptrCast(@alignCast(opq));
    return draw(self, ctx);
}

pub fn draw(
    self: *Self,
    ctx: vxfw.DrawContext,
) std.mem.Allocator.Error!vxfw.Surface {
    const app: *App = @ptrCast(@alignCast(self.model));

    var buffer: [16]u8 = undefined;
    const str_len = std.fmt.bufPrintZ(&buffer, "{d}", .{app.saved_queryes.items.len}) catch unreachable;

    const file_name: vxfw.Text = .{ .text = str_len };
    const label = if (self.focused) "[Data]" else "Data";

    const cp_name: vxfw.Text = .{ .text = label };

    const cp_name_surface: vxfw.SubSurface = .{
        //
        .origin = .{ .row = 0, .col = 1 },
        .surface = try cp_name.draw(ctx.withConstraints(ctx.min, .{ .width = 6, .height = 1 })),
    };

    const border: vxfw.Border = .{
        .child = file_name.widget(),
    };

    const sb: vxfw.SizedBox = .{ .child = border.widget(), .size = .{ .width = (ctx.max.width orelse 0), .height = (ctx.max.height orelse 0) - 2 } };

    const file_name_surface: vxfw.SubSurface = .{
        .origin = .{ .row = 0, .col = 0 },
        //
        .surface = try sb.widget().draw(ctx.withConstraints(ctx.min, ctx.max)),
    };

    const childs = try ctx.arena.alloc(vxfw.SubSurface, 2);
    childs[0] = file_name_surface;
    childs[1] = cp_name_surface;

    const surface = try vxfw.Surface.initWithChildren(ctx.arena, self.widget(), ctx.max.size(), childs);
    return surface;
}
