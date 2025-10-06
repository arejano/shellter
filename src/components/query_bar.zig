const std = @import("std");
const vaxis = @import("vaxis");
const vxfw = vaxis.vxfw;

const App = @import("../App.zig");
const Self = @This();

model: *App,
allocator: std.mem.Allocator,

focused: bool = false,

input: vxfw.TextField,

pub fn init(model: *App, allocator: std.mem.Allocator) std.mem.Allocator.Error!Self {
    const app: *App = @ptrCast(@alignCast(model));

    return .{
        .model = model,
        .allocator = allocator,
        .input = .{
            .buf = vxfw.TextField.Buffer.init(allocator),
            .unicode = &app.vaxis_app.vx.unicode,
            .userdata = model,
            .onChange = Self.onChangeInput,
            .onSubmit = Self.onSubmitInput,
        },
    };
}

pub fn onChangeInput(opq: ?*anyopaque, _: *vxfw.EventContext, str: []const u8) anyerror!void {
    const ptr = opq orelse return;
    const self: *App = @ptrCast(@alignCast(ptr));
    _ = self;
    _ = str;
}

pub fn onSubmitInput(opq: ?*anyopaque, _: *vxfw.EventContext, str: []const u8) anyerror!void {
    const ptr = opq orelse return;
    const app: *App = @ptrCast(@alignCast(ptr));
    try app.saved_queryes.append(str);
}

pub fn deinit(self: *Self) void {
    self.input.deinit();
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
                try ctx.requestFocus(self.input.widget());
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
    // const file_name: vxfw.Text = .{ .text = "QueryBar" };
    const label = if (self.focused) "[Query]" else "Query";

    const cp_name: vxfw.Text = .{ .text = label };

    const cp_name_surface: vxfw.SubSurface = .{
        //
        .origin = .{ .row = 0, .col = 1 },
        .surface = try cp_name.draw(ctx.withConstraints(ctx.min, .{ .width = 7, .height = 1 })),
    };

    const border: vxfw.Border = .{
        .child = self.input.widget(),
    };

    const sb: vxfw.SizedBox = .{ .child = border.widget(), .size = .{ .width = (ctx.max.width orelse 0), .height = 1 } };

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
