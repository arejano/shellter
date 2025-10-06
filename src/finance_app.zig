const std = @import("std");
const vaxis = @import("vaxis");
const vxfw = vaxis.vxfw;

const AccountsList = @import("components//accounts_list.zig");

const Self = @This();

//Need
vaxis_app: *vxfw.App,
model: *Self,
allocator: std.mem.Allocator,

//Components
account_list: *AccountsList,
records_list: *AccountsList,
insights_list: *AccountsList,
//Status

//Query

pub fn init(model: *Self, vaxis_app: *vxfw.App, allocator: std.mem.Allocator) !Self {
    const accounts_component_model = try allocator.create(AccountsList);
    accounts_component_model.* = try AccountsList.init(accounts_component_model, vaxis_app, allocator);

    const records_component_model = try allocator.create(AccountsList);
    records_component_model.* = try AccountsList.init(records_component_model, vaxis_app, allocator);

    const insights_component_model = try allocator.create(AccountsList);
    insights_component_model.* = try AccountsList.init(insights_component_model, vaxis_app, allocator);

    return .{
        .model = model,
        .vaxis_app = vaxis_app,
        .allocator = allocator,
        .account_list = accounts_component_model,
        .records_list = records_component_model,
        .insights_list = insights_component_model,
    };
}

pub fn deinit(self: *Self) void {
    const account_list: *AccountsList = @ptrCast(@alignCast(self.account_list));
    account_list.deinit();

    const records_list: *AccountsList = @ptrCast(@alignCast(self.records_list));
    records_list.deinit();

    const insig_list: *AccountsList = @ptrCast(@alignCast(self.insights_list));
    insig_list.deinit();

    self.allocator.destroy(self.account_list);
    self.allocator.destroy(self.records_list);
    self.allocator.destroy(self.insights_list);
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
    _ = self;
    switch (event) {
        .key_press => |key| {
            if (key.matches('c', .{ .ctrl = true })) {
                ctx.quit = true;
                ctx.redraw = true;
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
    const accounts_surface: vxfw.SubSurface = .{
        //
        .origin = .{ .row = 0, .col = 0 },
        .surface = try self.account_list.widget().draw(ctx.withConstraints(ctx.min, .{ .width = 20, .height = 8 })),
    };

    const records_surface: vxfw.SubSurface = .{
        //
        .origin = .{ .row = 8, .col = 0 },
        .surface = try self.records_list.widget().draw(ctx.withConstraints(ctx.min, .{ .width = 20, .height = (ctx.max.height orelse 0) - 8 })),
    };

    const insights_surface: vxfw.SubSurface = .{
        //
        .origin = .{ .row = 0, .col = 21 },
        .surface = try self.insights_list.widget().draw(ctx.withConstraints(ctx.min, .{ .width = (ctx.max.width orelse 0) - 21, .height = (ctx.max.height orelse 0) })),
    };

    const childs = try ctx.arena.alloc(vxfw.SubSurface, 3);
    childs[0] = accounts_surface;
    childs[1] = records_surface;
    childs[2] = insights_surface;

    const surface = try vxfw.Surface.initWithChildren(ctx.arena, self.widget(), ctx.max.size(), childs);
    return surface;
}
