const std = @import("std");

//--vaxis
const vaxis = @import("vaxis");
const vxfw = vaxis.vxfw;

//--model
const Dashboard = @import("dashboard.zig");

const Allocator = std.mem.Allocator;

pub fn typeErasedDrawFn(ptr: *anyopaque, ctx: vxfw.DrawContext) std.mem.Allocator.Error!vxfw.Surface {
    const self: *Dashboard = @ptrCast(@alignCast(ptr));
    return draw(self, ctx);
}

fn draw(self: *Dashboard, ctx: vxfw.DrawContext) Allocator.Error!vxfw.Surface {
    //FIleName
    const file_name: vxfw.Text = .{ .text = self.title, .softwrap = true };
    const file_name_surface: vxfw.SubSurface = .{
        .origin = .{ .row = 0, .col = 0 },
        .surface = try file_name.draw(ctx.withConstraints(ctx.min, .{ .width = ctx.max.width, .height = 1 })),
    };

    //Title
    // const title: vxfw.Text = .{ .text = self.mouse_point };
    // const title_surface: vxfw.SubSurface = .{
    //     .origin = .{ .row = 0, .col = 0 },
    //     .surface = try title.draw(ctx.withConstraints(ctx.min, .{ .width = ctx.max.width, .height = 1 })),
    // };

    const childs = try ctx.arena.alloc(vxfw.SubSurface, 1);
    childs[0] = file_name_surface;
    // childs[1] = title_surface;

    const surface = try vxfw.Surface.initWithChildren(
        ctx.arena,
        self.widget(),
        ctx.max.size(),
        childs,
    );
    return surface;
}
