const std = @import("std");
const ui_utils = @import("ui_utils.zig");

const vaxis = @import("vaxis");
const vxfw = vaxis.vxfw;

const App = @import("App.zig");
const Editor = @This();

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
) Editor {
    return .{ .model = model, .allocator = allocator };
}

pub fn widget(self: *Editor) vxfw.Widget {
    return .{
        .userdata = self,
        .eventHandler = typeErasedEventHandler,
        .drawFn = typeErasedDrawFn,
    };
}

pub fn typeErasedEventHandler(ptr: *anyopaque, ctx: *vxfw.EventContext, event: vxfw.Event) anyerror!void {
    const self: *Editor = @ptrCast(@alignCast(ptr));
    return handleEvent(self, ctx, event);
}

pub fn handleEvent(self: *Editor, ctx: *vxfw.EventContext, event: vxfw.Event) anyerror!void {
    switch (event) {
        .key_press => |_| {},
        .mouse => |_| {
            // if (mouse.type == .press) {
            //     const app: *App = @ptrCast(@alignCast(self.model));
            //     app.focused_component = .Editor;
            //     ctx.redraw = true;
            // }
        },
        .mouse_enter => {
            std.debug.print("MouseEnter:Editor", .{});
            self.has_mouse = true;
            try ctx.setMouseShape(.pointer);
            return ctx.consumeAndRedraw();
        },
        .mouse_leave => {
            std.debug.print("MouseLeave:Editor\n", .{});
            self.has_mouse = false;
            try ctx.setMouseShape(.default);
            return ctx.consumeAndRedraw();
        },
        .focus_in => {
            std.debug.print("FocusIn:Editor\n", .{});
            self.focused = true;
            ctx.redraw = true;
        },
        .focus_out => {
            std.debug.print("FocusOut:Editor", .{});
            self.focused = false;
            ctx.redraw = true;
        },
        else => {},
    }
}

pub fn typeErasedDrawFn(ptr: *anyopaque, ctx: vxfw.DrawContext) std.mem.Allocator.Error!vxfw.Surface {
    const self: *Editor = @ptrCast(@alignCast(ptr));
    return draw(self, ctx);
}

pub fn draw(self: *Editor, ctx: vxfw.DrawContext) std.mem.Allocator.Error!vxfw.Surface {
    const style: vaxis.Style = if (self.focused)
        self.style.focus
    else
        self.style.default;

    const empty_buffer: vxfw.Text = .{ .text = "Empty Buffer", .style = style };
    // const center: vxfw.Center = .{ .child = empty_buffer.widget() };
    const sized: vxfw.SizedBox = .{ .child = empty_buffer.widget(), .size = .{ .width = (ctx.max.width orelse 0), .height = (ctx.max.height orelse 0) } };
    const sub_surface: vxfw.SubSurface = .{
        //
        .origin = .{ .row = 1, .col = 0 },
        .surface = try sized.widget().draw(ctx),
    };

    const childs = try ctx.arena.alloc(vxfw.SubSurface, 2);
    childs[0] = try ui_utils.component_title("Editor", ctx, 0, 0, (ctx.max.width orelse 0), 1, style);
    childs[1] = sub_surface;

    // @memset(sub_surface.surface.buffer, .{ .style = style });

    const surface = try vxfw.Surface.initWithChildren(
        ctx.arena,
        self.widget(),
        ctx.max.size(),
        childs,
    );
    return surface;
}

pub fn SubSurf(w: vxfw.Widget, ctx: vxfw.DrawContext, row: i17, col: i17, width: u16, height: u16) std.mem.Allocator.Error!vxfw.SubSurface {
    const surface: vxfw.SubSurface = .{
        //
        .origin = .{ .row = row, .col = col },
        .surface = try w.draw(ctx.withConstraints(ctx.min, .{ .width = width, .height = height })),
    };
    return surface;
}
