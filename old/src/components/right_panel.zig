const std = @import("std");
const vaxis = @import("vaxis");
const vxfw = vaxis.vxfw;
const Allocator = std.mem.Allocator;
const AppStyles = @import("../styles.zig");

const Button = vxfw.Button;

const RightPanelComponent = @This();

//State
component_name: []const u8 = "RightPanel",
mouse_down: bool = false,
has_mouse: bool = false,
counter: usize = 0,

pub fn init(model: *RightPanelComponent) RightPanelComponent {
    _ = model;
}

pub fn widget(self: *RightPanelComponent) vxfw.Widget {
    return .{
        .userdata = self,
        .eventHandler = typeErasedEventHandler,
        .drawFn = typeErasedDrawFn,
    };
}

pub fn widget_surface(self: *RightPanelComponent, ctx: vxfw.DrawContext, size: vxfw.Size) vxfw.SubSurface {
    const hw_text_surface: vxfw.SubSurface = .{
        //origin
        .origin = .{ .row = 1, .col = 0 },
        .surface = try self.draw(ctx.withConstraints(ctx.min, .{ .width = size.width, .height = size.height })),
    };
    return hw_text_surface;
}

fn typeErasedEventHandler(ptr: *anyopaque, ctx: *vxfw.EventContext, event: vxfw.Event) anyerror!void {
    const self: *RightPanelComponent = @ptrCast(@alignCast(ptr));
    return self.handleEvent(ctx, event);
}

fn typeErasedDrawFn(ptr: *anyopaque, ctx: vxfw.DrawContext) Allocator.Error!vxfw.Surface {
    const self: *RightPanelComponent = @ptrCast(@alignCast(ptr));
    return self.draw(ctx);
}

pub fn handleEvent(self: *RightPanelComponent, ctx: *vxfw.EventContext, event: vxfw.Event) anyerror!void {
    switch (event) {
        .key_press => |key| {
            if (key.matches('a', .{ .ctrl = false })) {
                // self.counter += 1;
                return;
            }
        },
        .mouse => |mouse| {
            if (self.mouse_down and mouse.type == .release) {
                self.mouse_down = false;
                self.has_mouse = !self.has_mouse;
                return ctx.consumeAndRedraw();
            }
            if (mouse.type == .press and mouse.button == .left) {
                self.mouse_down = true;
                return ctx.consumeAndRedraw();
            }
        },
        .focus_in => return ctx.requestFocus(self.widget()),
        .focus_out => {},
        .mouse_enter => {
            // self.has_mouse = true;
        },
        .mouse_leave => {
            // self.has_mouse = false;
        },

        else => {},
    }
}

fn onClick(maybe_ptr: ?*anyopaque, ctx: *vxfw.EventContext) anyerror!void {
    const ptr = maybe_ptr orelse return;
    const self: *RightPanelComponent = @ptrCast(@alignCast(ptr));
    self.counter += 1;
    return ctx.consumeAndRedraw();
}

pub fn draw(self: *RightPanelComponent, ctx: vxfw.DrawContext) Allocator.Error!vxfw.Surface {
    const max = ctx.max.size();

    const style = if (self.has_mouse) AppStyles.panel_name_dark_active() else AppStyles.panel_name_dark();

    // var button: Button = .{
    //     //
    //     .label = "Click",
    //     .onClick = RightPanelComponent.onClick,
    //     .userdata = self,
    // };

    // const button_surface: vxfw.SubSurface = .{
    //     //origin
    //     .origin = .{ .row = 1, .col = 0 },
    //     .surface = try button.draw(ctx.withConstraints(ctx.min, .{ .width = max.width, .height = 3 })),
    // };

    const label = try std.fmt.allocPrint(ctx.arena, "{s}:{d}", .{ self.component_name, self.counter });
    const panel_name: vxfw.Text = .{
        .text = label,
        .style = style,
    };

    const center: vxfw.Center = .{ .child = panel_name.widget() };

    const name_surface: vxfw.SubSurface = .{
        //origin
        .origin = .{ .row = 3, .col = 0 },
        .surface = try center.draw(ctx.withConstraints(ctx.min, .{ .width = max.width, .height = max.height })),
    };

    const childs = try ctx.arena.alloc(vxfw.SubSurface, 1);
    // childs[0] = button_surface;
    childs[0] = name_surface;

    const surface = try vxfw.Surface.initWithChildren(
        //alloc
        ctx.arena,
        self.widget(),
        // ms,
        max,
        childs,
    );
    // @memset(surface.buffer, .{ .style = style });
    return surface;
}
