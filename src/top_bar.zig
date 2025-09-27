const std = @import("std");
const ui_utils = @import("ui_utils.zig");

const vaxis = @import("vaxis");
const vxfw = vaxis.vxfw;

const App = @import("App.zig");
const TopBar = @This();
const styles = @import("styles.zig");

style: styles.StyleApp = styles.styles,

model: *App,

has_mouse: bool = false,
focused: bool = false,

pub fn init(
    model: *App,
) TopBar {
    return .{ .model = model };
}

pub fn deinit(self: *TopBar) void {
    _ = self;
    std.debug.print("deinit", .{});
}

pub fn widget(self: *TopBar) vxfw.Widget {
    return .{
        .userdata = self,
        .eventHandler = typeErasedEventHandler,
        .drawFn = typeErasedDrawFn,
    };
}

pub fn typeErasedEventHandler(ptr: *anyopaque, ctx: *vxfw.EventContext, event: vxfw.Event) anyerror!void {
    const self: *TopBar = @ptrCast(@alignCast(ptr));
    return handleEvent(self, ctx, event);
}

pub fn handleEvent(self: *TopBar, ctx: *vxfw.EventContext, event: vxfw.Event) anyerror!void {
    switch (event) {
        .key_press => |_| {},
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
    const self: *TopBar = @ptrCast(@alignCast(ptr));
    return draw(self, ctx);
}

pub fn draw(self: *TopBar, ctx: vxfw.DrawContext) std.mem.Allocator.Error!vxfw.Surface {
    const style: vaxis.Style = if (self.has_mouse)
        self.style.has_mouse
    else
        self.style.default;

    const childs = try ctx.arena.alloc(vxfw.SubSurface, 1);
    childs[0] = try ui_utils.component_title("top_bar", ctx, 0, 0, (ctx.max.width orelse 0), 1, style);

    const surface = try vxfw.Surface.initWithChildren(
        ctx.arena,
        self.widget(),
        ctx.max.size(),
        childs,
    );
    @memset(surface.buffer, .{ .style = self.style.default });
    return surface;
}
