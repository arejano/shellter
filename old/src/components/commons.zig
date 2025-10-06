const vaxis = @import("vaxis");
const vxfw = vaxis.vxfw;

const Commons = @This();

pub fn spliter(ctx: vxfw.DrawContext, row: i17, col: i17) !vxfw.SubSurface {
    const max = ctx.max.size();
    const empty: vxfw.Text = .{
        .text = "bla",
        .text_align = .center,
        .style = .{ .reverse = false },
    };
    const center: vxfw.Center = .{ .child = empty.widget() };

    const sub: vxfw.SubSurface = .{
        //origin
        .origin = .{ .row = row, .col = col },
        .surface = try center.draw(ctx.withConstraints(ctx.min, .{ .width = max.width, .height = 1 })),
    };
    return sub;
}
