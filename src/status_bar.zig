const std = @import("std");
const ui_utils = @import("ui_utils.zig");

const vaxis = @import("vaxis");
const vxfw = vaxis.vxfw;

const App = @import("App.zig");
const StatusBar = @This();

const styles = @import("styles.zig");

style: styles.StyleApp = styles.styles,

model: *App,
allocator: std.mem.Allocator,

// states
has_mouse: bool = false,
focused: bool = false,

pub fn init(
    model: *App,
    allocator: std.mem.Allocator,
) StatusBar {
    return .{ .model = model, .allocator = allocator };
}

pub fn widget(self: *StatusBar) vxfw.Widget {
    return .{
        .userdata = self,
        .eventHandler = typeErasedEventHandler,
        .drawFn = typeErasedDrawFn,
    };
}

pub fn typeErasedEventHandler(ptr: *anyopaque, ctx: *vxfw.EventContext, event: vxfw.Event) anyerror!void {
    const self: *StatusBar = @ptrCast(@alignCast(ptr));
    return handleEvent(self, ctx, event);
}

pub fn handleEvent(self: *StatusBar, ctx: *vxfw.EventContext, event: vxfw.Event) anyerror!void {
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
    const self: *StatusBar = @ptrCast(@alignCast(ptr));
    return draw(self, ctx);
}

pub fn draw(self: *StatusBar, ctx: vxfw.DrawContext) std.mem.Allocator.Error!vxfw.Surface {
    const app: *App = @ptrCast(@alignCast(self.model));

    const style: vaxis.Style = if (self.has_mouse)
        self.style.has_mouse
    else
        self.style.default;

    const childs = try ctx.arena.alloc(vxfw.SubSurface, 1);
    childs[0] = try ui_utils.component_title(app.focused_label, ctx, 0, 0, (ctx.max.width orelse 0), 1, style);

    const surface = try vxfw.Surface.initWithChildren(
        ctx.arena,
        self.widget(),
        ctx.max.size(),
        childs,
    );
    return surface;
}
