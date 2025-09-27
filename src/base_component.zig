const std = @import("std");

const vaxis = @import("vaxis");
const vxfw = vaxis.vxfw;

const App = @import("App.zig");
const BaseComponent = @This();

model: *App,

// states
has_mouse: bool = false,
focused: bool = false,

pub fn init(
    model: *App,
) BaseComponent {
    return .{ .model = model };
}

pub fn widget(self: *BaseComponent) vxfw.Widget {
    return .{
        .userdata = self,
        .eventHandler = typeErasedEventHandler,
        .drawFn = typeErasedDrawFn,
    };
}

pub fn typeErasedEventHandler(ptr: *anyopaque, ctx: *vxfw.EventContext, event: vxfw.Event) anyerror!void {
    const self: *BaseComponent = @ptrCast(@alignCast(ptr));
    return handleEvent(self, ctx, event);
}

pub fn handleEvent(self: *BaseComponent, ctx: *vxfw.EventContext, event: vxfw.Event) anyerror!void {
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
    const self: *BaseComponent = @ptrCast(@alignCast(ptr));
    return draw(self, ctx);
}

pub fn draw(self: *BaseComponent, ctx: vxfw.DrawContext) std.mem.Allocator.Error!vxfw.Surface {
    const name: vxfw.Text = .{ .text = "BaseComponent" };
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
