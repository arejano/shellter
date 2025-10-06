const std = @import("std");
const vaxis = @import("vaxis");
const vxfw = vaxis.vxfw;

const QueryBarComponent = @import("components/query_bar.zig");
const MainListComponent = @import("components/main_list.zig");
const LeftPanelComponent = @import("components/left_panel.zig");

const AppData = @import("app_data.zig").AppData;

const Self = @This();

//Need
vaxis_app: *vxfw.App,
model: *Self,
allocator: std.mem.Allocator,

//Components
query_bar: QueryBarComponent,
main_list: MainListComponent,
left_panel: LeftPanelComponent,

//Status
left_panel_size: u16 = 20,
show_left_panel: bool = true,
menus: std.array_list.Managed(vxfw.Text) = undefined,

//Query
query_text: []const u8 = "",
saved_queryes: std.array_list.Managed([]const u8),

data: *AppData,

pub fn init(model: *Self, vaxis_app: *vxfw.App, allocator: std.mem.Allocator) !Self {
    const query_bar = try QueryBarComponent.init(model, allocator);
    const main = try MainListComponent.init(model, allocator);
    const left_panel = try LeftPanelComponent.init(model, allocator);

    var menus = std.array_list.Managed(vxfw.Text).init(allocator);

    const app_data = try allocator.create(AppData);
    app_data.* = try AppData.init(allocator);

    // INSTANCIAS os AppData no allocator e limpar
    //Saber se algo pode guardar tudo.

    try menus.append(.{ .text = "Menu A" });
    try menus.append(.{ .text = "Memu B" });
    try menus.append(.{ .text = "Memu C" });
    try menus.append(.{ .text = "Memu D" });
    try menus.append(.{ .text = "Memu E" });
    try menus.append(.{ .text = "Memu F" });
    try menus.append(.{ .text = "Memu G" });

    return .{
        .model = model,
        .vaxis_app = vaxis_app,
        .allocator = allocator,
        .query_bar = query_bar,
        .main_list = main,
        .left_panel = left_panel,
        .saved_queryes = std.array_list.Managed([]const u8).init(allocator),
        .menus = menus,
        .data = app_data,
    };
}

pub fn deinit(self: *Self) void {
    self.menus.deinit();
    self.query_bar.deinit();
    self.saved_queryes.deinit();
    self.left_panel.deinit();

    const app_data: *AppData = @ptrCast(@alignCast(self.data));
    app_data.deinit();

    self.allocator.destroy(self.data);
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
    switch (event) {
        .key_press => |key| {
            if (key.matches('c', .{ .ctrl = true })) {
                ctx.quit = true;
                ctx.redraw = true;
            }
            if (key.matches('e', .{ .ctrl = true })) {
                self.show_left_panel = !self.show_left_panel;
                ctx.redraw = true;
            }

            if (key.matches('f', .{ .ctrl = true })) {
                std.debug.print("Limpando a lista de querie salvas\n", .{});
                self.saved_queryes.clearAndFree();
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
    const r_size = (ctx.max.width orelse 0) - self.left_panel_size;
    const l_size = if (self.show_left_panel) self.left_panel_size else 0;
    const right_size = if (self.show_left_panel) r_size else ctx.max.width;

    const query_bar_surface: vxfw.SubSurface = .{
        .origin = .{ .row = 0, .col = l_size },
        .surface = try self.query_bar.draw(ctx.withConstraints(ctx.min, .{ .width = right_size, .height = 3 })),
    };

    const main_list_surface: vxfw.SubSurface = .{
        //
        .origin = .{ .row = 3, .col = l_size },
        .surface = try self.main_list.draw(ctx.withConstraints(ctx.min, .{ .width = right_size, .height = (ctx.max.height orelse 0) - 3 })),
    };

    const left_panel_surface: vxfw.SubSurface = .{
        //
        .origin = .{ .row = 2, .col = 0 },
        .surface = try self.left_panel.draw(ctx.withConstraints(ctx.min, .{ .width = l_size, .height = (ctx.max.height orelse 0) - 2 })),
    };

    const childs = try ctx.arena.alloc(vxfw.SubSurface, 3);
    childs[0] = query_bar_surface;
    childs[1] = main_list_surface;
    childs[2] = left_panel_surface;

    const surface = try vxfw.Surface.initWithChildren(ctx.arena, self.widget(), ctx.max.size(), childs);
    return surface;
}

pub fn selectMenu(self: *Self, idx: usize) void {
    std.debug.print("APP:{any}\n", .{self.menus.items[idx].text});
}

pub fn onClick(opq: *anyopaque, ctx: *vxfw.EventContext) anyerror!void {
    const self: *Self = @ptrCast(@alignCast(opq));
    _ = self;
    ctx.consumeAndRedraw();
}
