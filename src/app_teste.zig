const std = @import("std");
const vaxis = @import("vaxis");
const vxfw = vaxis.vxfw;

const Panel = @import("components//panel.zig");

const Self = @This();

style: struct {
    default: vaxis.Style = .{ .reverse = true },
    mouse_down: vaxis.Style = .{ .fg = .{ .index = 4 }, .reverse = true },
    hover: vaxis.Style = .{ .fg = .{ .index = 3 }, .reverse = true },
    focus: vaxis.Style = .{ .fg = .{ .index = 5 }, .reverse = true },
} = .{},

//Need
model: *Self,
allocator: std.mem.Allocator,
vaxis_app: *vxfw.App = undefined,

//Components
list_view: vxfw.ListView,
menus: std.array_list.Managed(vxfw.Text),

pub fn init(model: *Self, vaxis_app: *vxfw.App, allocator: std.mem.Allocator) !Self {
    var menus: std.array_list.Managed(vxfw.Text) = std.array_list.Managed(vxfw.Text).init(allocator);

    try menus.append(.{ .text = "Francisco" });
    try menus.append(.{ .text = "Gustavo" });
    try menus.append(.{ .text = "Juliana" });
    try menus.append(.{ .text = "Juliana" });
    try menus.append(.{ .text = "Juliana" });
    try menus.append(.{ .text = "Juliana" });
    try menus.append(.{ .text = "Juliana" });
    try menus.append(.{ .text = "Juliana" });
    try menus.append(.{ .text = "Juliana" });
    try menus.append(.{ .text = "Juliana" });
    try menus.append(.{ .text = "Juliana" });
    try menus.append(.{ .text = "Juliana" });
    try menus.append(.{ .text = "Juliana" });
    try menus.append(.{ .text = "Juliana" });
    try menus.append(.{ .text = "Juliana" });
    try menus.append(.{ .text = "Juliana" });
    try menus.append(.{ .text = "Juliana" });
    try menus.append(.{ .text = "Juliana" });
    try menus.append(.{ .text = "Juliana" });
    try menus.append(.{ .text = "Juliana" });
    try menus.append(.{ .text = "Juliana" });
    try menus.append(.{ .text = "Juliana" });
    try menus.append(.{ .text = "Juliana" });
    try menus.append(.{ .text = "Juliana" });
    try menus.append(.{ .text = "Juliana" });
    try menus.append(.{ .text = "Juliana" });
    try menus.append(.{ .text = "Juliana" });
    try menus.append(.{ .text = "Juliana" });
    try menus.append(.{ .text = "Juliana" });
    try menus.append(.{ .text = "Juliana" });
    try menus.append(.{ .text = "Juliana" });
    try menus.append(.{ .text = "Juliana" });
    try menus.append(.{ .text = "Juliana" });
    try menus.append(.{ .text = "Juliana" });
    try menus.append(.{ .text = "Juliana" });
    try menus.append(.{ .text = "Juliana" });
    try menus.append(.{ .text = "Juliana" });
    try menus.append(.{ .text = "Juliana" });
    try menus.append(.{ .text = "Juliana" });
    try menus.append(.{ .text = "Juliana" });
    try menus.append(.{ .text = "Juliana" });
    try menus.append(.{ .text = "Juliana" });
    try menus.append(.{ .text = "Juliana" });
    try menus.append(.{ .text = "Juliana" });
    try menus.append(.{ .text = "Juliana" });
    try menus.append(.{ .text = "Juliana" });
    try menus.append(.{ .text = "Juliana" });
    try menus.append(.{ .text = "Juliana" });
    try menus.append(.{ .text = "Juliana" });
    try menus.append(.{ .text = "Juliana" });
    try menus.append(.{ .text = "Juliana" });
    try menus.append(.{ .text = "Juliana" });
    try menus.append(.{ .text = "Juliana" });
    try menus.append(.{ .text = "Pedro" });

    return .{
        .model = model,
        .vaxis_app = vaxis_app,
        .allocator = allocator,
        .menus = menus,
        .list_view = .{
            //
            .children = .{
                //
                .builder = .{
                    //
                    .userdata = model,
                    .buildFn = Self.widgetBuilder,
                },
            },
        },
    };
}

pub fn deinit(self: *Self) void {
    self.menus.deinit();
}

pub fn widgetBuilder(opq: *const anyopaque, idx: usize, _: usize) ?vxfw.Widget {
    const self: *const Self = @ptrCast(@alignCast(opq));
    if (idx >= self.menus.items.len) return null;

    return self.menus.items[idx].widget();
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
    switch (event) {
        .init => |_| {},
        .key_press => |key| {
            if (key.matches('c', .{ .ctrl = true })) {
                ctx.quit = true;
                ctx.redraw = true;
            }
            if (key.codepoint == vaxis.Key.enter) {
                self.selectItem(ctx);
            }
        },
        .mouse => |_| {},
        .mouse_enter => {},
        .mouse_leave => {},
        .focus_in => {},
        .focus_out => {},
        else => {},
    }
}

pub fn selectItem(self: *Self, ctx: *vxfw.EventContext) void {
    std.debug.print("{s}", .{self.menus.items[self.list_view.cursor].text});
    self.menus.items[self.list_view.cursor] = .{ .text = "Novo Item" };

    return ctx.consumeAndRedraw();
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
    const teste1: vxfw.Text = .{ .text = "Jorge aragao" };
    const teste: vxfw.Text = .{ .text = "Jorge Eduardo" };

    var panel: Panel = .{ .label = "Teste", .child = teste1.widget() };
    var second_panel: Panel = .{ .label = "SecondPanel", .child = teste.widget() };

    const half_size = (ctx.max.width orelse 0) / 2;

    const childs = try ctx.arena.alloc(vxfw.SubSurface, 2);
    childs[0] = try sub(ctx, panel.widget(), 0, 0, (ctx.max.width orelse 0) / 2, ctx.max.height orelse 0);
    childs[1] = try sub(ctx, second_panel.widget(), 0, half_size, half_size, ctx.max.height orelse 0);

    const surface = try vxfw.Surface.initWithChildren(ctx.arena, self.widget(), ctx.max.size(), childs);
    return surface;
}

pub fn sub(ctx: vxfw.DrawContext, wdg: vxfw.Widget, row: i17, col: i17, w: ?u16, h: ?u16) std.mem.Allocator.Error!vxfw.SubSurface {
    return .{
        .origin = .{ .row = row, .col = col },
        .surface = try wdg.draw(ctx.withConstraints(ctx.min, .{
            .width = w,
            .height = h,
        })),
    };
}
