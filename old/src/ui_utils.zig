const std = @import("std");
const vaxis = @import("vaxis");
const vxfw = vaxis.vxfw;

pub fn sub_surface(
    w: vxfw.Widget,
    ctx: vxfw.DrawContext,
    row: i17,
    col: i17,
    width: u16,
    height: u16,
) std.mem.Allocator.Error!vxfw.SubSurface {
    const surface: vxfw.SubSurface = .{
        .origin = .{ .row = row, .col = col },
        .surface = try w.draw(ctx.withConstraints(ctx.min, .{ .width = width, .height = height })),
    };
    return surface;
}

pub fn component_title(
    text: []const u8,
    ctx: vxfw.DrawContext,
    row: i17,
    col: i17,
    width: u16,
    height: u16,
    style: vaxis.Style,
) std.mem.Allocator.Error!vxfw.SubSurface {
    const component: vxfw.Text = .{ .text = text, .style = style };
    const component_title_sized_box: vxfw.SizedBox = .{ .child = component.widget(), .size = .{ .width = (ctx.max.width orelse 0), .height = height } };

    const component_title_surface: vxfw.SubSurface = .{
        .origin = .{ .row = row, .col = col },
        .surface = try component_title_sized_box.widget().draw(ctx.withConstraints(ctx.min, .{ .width = width, .height = height })),
    };
    return component_title_surface;
}
