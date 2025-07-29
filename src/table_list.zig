const std = @import("std");
const vaxis = @import("vaxis");
const vxfw = vaxis.vxfw;

const AppStyles = @import("styles.zig");

const Allocator = std.mem.Allocator;

const Center = vxfw.Center;
const Text = vxfw.Text;

const TableList = @This();

pub fn init() TableList {
    return .{};
}

pub fn widget(self: *TableList) vxfw.Widget {
    return .{
        .userdata = self,
        .eventHandler = typeErasedEventHandler,
        .drawFn = typeErasedDrawFn,
    };
}

fn typeErasedEventHandler(ptr: *anyopaque, ctx: *vxfw.EventContext, event: vxfw.Event) anyerror!void {
    const self: *TableList = @ptrCast(@alignCast(ptr));
    return self.handleEvent(ctx, event);
}

pub fn handleEvent(_: *TableList, _: *vxfw.EventContext, event: vxfw.Event) anyerror!void {
    switch (event) {
        .key_press => |key| {
            if (key.matches(vaxis.Key.enter, .{}) or key.matches('j', .{ .ctrl = true })) {}
        },
        .mouse => |_| {},
        .mouse_enter => {},
        .mouse_leave => {},
        .focus_in => {},
        .focus_out => {},
        else => {},
    }
}

fn typeErasedDrawFn(ptr: *anyopaque, ctx: vxfw.DrawContext) Allocator.Error!vxfw.Surface {
    const self: *TableList = @ptrCast(@alignCast(ptr));
    return self.draw(ctx);
}

fn doClick(self: *TableList, ctx: *vxfw.EventContext) anyerror!void {
    try self.onClick(self.userdata, ctx);
    ctx.consume_event = true;
}

pub fn draw(self: *TableList, ctx: vxfw.DrawContext) Allocator.Error!vxfw.Surface {
    const title: Text = .{
        .text = "Tables",
        .text_align = .center,
    };

    const title_subsurface: vxfw.SubSurface = .{
        //origin
        .origin = .{ .row = 0, .col = 2 },
        .surface = try title.draw(ctx),
    };

    const text: Text = .{
        .text = "",
        .text_align = .center,
    };
    const size: vxfw.Size = .{ .width = (ctx.max.width orelse 0), .height = @intCast((ctx.max.height orelse 0) - 1) };

    const sized_box: vxfw.SizedBox = .{ .child = text.widget(), .size = size };
    const container: vxfw.Border = .{ .child = sized_box.widget() };

    const text_surface: vxfw.SubSurface = .{
        .origin = .{ .row = 0, .col = 0 },
        .surface = try container.draw(ctx),
    };

    const childs = try ctx.arena.alloc(vxfw.SubSurface, 2);
    childs[0] = text_surface;
    childs[1] = title_subsurface;

    const button_surf = try vxfw.Surface.initWithChildren(ctx.arena, self.widget(), ctx.max.size(), childs);

    @memset(button_surf.buffer, .{ .style = AppStyles.dark_background() });
    return button_surf;
}
