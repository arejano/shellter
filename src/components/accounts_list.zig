const std = @import("std");
const vaxis = @import("vaxis");
const vxfw = vaxis.vxfw;

const FinanceApp = @import("../finance_app.zig");
const Panel = @import("panel.zig");

const Self = @This();

//Need
vaxis_app: *vxfw.App,
model: *Self,
allocator: std.mem.Allocator,

//Components
list_view: vxfw.ListView,

accounts: std.array_list.Managed(vxfw.Text),

pub fn init(model: *Self, vaxis_app: *vxfw.App, allocator: std.mem.Allocator) !Self {
    var acts: std.array_list.Managed(vxfw.Text) = std.array_list.Managed(vxfw.Text).init(allocator);
    try acts.append(.{ .text = "Nubank" });
    try acts.append(.{ .text = "Nubank PJ" });
    try acts.append(.{ .text = "Mercado Livre" });
    try acts.append(.{ .text = "Inter" });
    try acts.append(.{ .text = "Caixa" });
    try acts.append(.{ .text = "Caixa" });
    try acts.append(.{ .text = "Caixa" });
    try acts.append(.{ .text = "Nubank PJ" });
    try acts.append(.{ .text = "Caixa" });
    try acts.append(.{ .text = "Caixa" });
    try acts.append(.{ .text = "Caixa" });
    try acts.append(.{ .text = "Nubank PJ" });
    try acts.append(.{ .text = "Caixa" });
    try acts.append(.{ .text = "Caixa" });
    try acts.append(.{ .text = "Caixa" });
    try acts.append(.{ .text = "Nubank PJ" });
    try acts.append(.{ .text = "Caixa" });
    try acts.append(.{ .text = "Caixa" });
    try acts.append(.{ .text = "Nubank PJ" });
    try acts.append(.{ .text = "Caixa" });
    try acts.append(.{ .text = "Caixa" });

    return .{
        .model = model,
        .vaxis_app = vaxis_app,
        .allocator = allocator,
        .accounts = acts,
        .list_view = .{
            .children = .{
                //
                .builder = .{
                    //

                    .buildFn = Self.widgetBuilder,
                    .userdata = model,
                },
            },
        },
    };
}

pub fn deinit(self: *Self) void {
    self.accounts.clearAndFree();
}

pub fn widgetBuilder(opq: *const anyopaque, idx: usize, _: usize) ?vxfw.Widget {
    const self: *const Self = @ptrCast(@alignCast(opq));
    if (idx >= self.accounts.items.len) return null;

    return self.accounts.items[idx].widget();
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
    switch (event) {
        .init => |_| {
            // try ctx.requestFocus(self.list_view.widget());
            // ctx.redraw = true;
        },
        .key_press => |_| {},
        .mouse => |_| {},
        .mouse_enter => {
            try ctx.requestFocus(self.list_view.widget());
            ctx.redraw = true;
        },
        .mouse_leave => {},
        .focus_in => {},
        .focus_out => {},
        else => {},
    }
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
    var panel: Panel = .{ .child = self.list_view.widget(), .label = "Accounts" };

    const left_panel_surface: vxfw.SubSurface = .{
        //
        .origin = .{ .row = 0, .col = 0 },
        .surface = try panel.widget().draw(ctx.withConstraints(ctx.min, .{ .width = (ctx.max.width orelse 0), .height = (ctx.max.height orelse 0) })),
    };

    const childs = try ctx.arena.alloc(vxfw.SubSurface, 1);
    childs[0] = left_panel_surface;

    const surface = try vxfw.Surface.initWithChildren(ctx.arena, self.widget(), ctx.max.size(), childs);

    // @memset(surface.buffer, .{ .style = self.style.hover });
    return surface;
}
