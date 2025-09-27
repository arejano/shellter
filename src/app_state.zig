const vaxis = @import("vaxis");
const vxfw = vaxis.vxfw;
const std = @import("std");
const Allocator = std.mem.Allocator;
const Text = vxfw.Text;

const AppMenu = @import("app_menu.zig");
const AppState = @This();
const AppStatus = @import("app_status.zig");
const DatabaseList = @import("database_list.zig");
const TableList = @import("table_list.zig");
const QueryBox = @import("query_box.zig");
const ResultBox = @import("result_box.zig");

userdata: ?*anyopaque,
app: *vxfw.App,

app_menu: AppMenu,
app_status: AppStatus,
database_list: DatabaseList,
table_list: TableList,
query_box: QueryBox,
result_box: ResultBox,

left_block_width: u16 = 40,
database_height: u16 = 10,
result_height: u16 = 33,
query_box_height: u16 = 18,

filtered: std.ArrayList(vxfw.RichText),

pub fn init(
    model: *AppState,
    app: *vxfw.App,
    allocator: Allocator,
) !AppState {
    const vx_app: *vxfw.App = @ptrCast(@alignCast(app));

    const app_menu: AppMenu = AppMenu.init();
    const app_status: AppStatus = AppStatus.init();
    const database_list: DatabaseList = DatabaseList.init(allocator);
    const table_list: TableList = TableList.init();
    const query_box: QueryBox = try QueryBox.init(allocator);
    const result_box: ResultBox = ResultBox.init();

    return .{
        .filtered = std.ArrayList(vxfw.RichText).init(allocator),
        .app_status = app_status,
        .app_menu = app_menu,
        .database_list = database_list,
        .table_list = table_list,
        .query_box = query_box,
        .result_box = result_box,
        .userdata = model,
        .app = vx_app,
    };
}
fn typeErasedEventHandler(ptr: *anyopaque, ctx: *vxfw.EventContext, event: vxfw.Event) anyerror!void {
    const self: *AppState = @ptrCast(@alignCast(ptr));
    return self.handleEvent(ctx, event);
}

fn typeErasedDrawFn(ptr: *anyopaque, ctx: vxfw.DrawContext) Allocator.Error!vxfw.Surface {
    const self: *AppState = @ptrCast(@alignCast(ptr));
    return self.draw(ctx);
}

pub fn handleEvent(_: *AppState, ctx: *vxfw.EventContext, event: vxfw.Event) anyerror!void {
    switch (event) {
        .init => {},
        .key_press => |key| {
            if (key.matches('c', .{ .ctrl = true })) {
                ctx.quit = true;
                return;
            }
        },
        .focus_in => {},
        .focus_out => {},
        .mouse => {},
        else => {},
    }
}

fn onClick(maybe_ptr: ?*anyopaque, ctx: *vxfw.EventContext) anyerror!void {
    const ptr = maybe_ptr orelse return;
    const self: *AppState = @ptrCast(@alignCast(ptr));
    self.counter +|= 1;
    return ctx.consumeAndRedraw();
}

pub fn deinit(self: *AppState) void {
    self.filtered.deinit();
    self.database_list.deinit();
}

pub fn widget(self: *AppState) vxfw.Widget {
    return .{
        .userdata = self,
        .eventHandler = typeErasedEventHandler,
        .drawFn = typeErasedDrawFn,
    };
}

pub fn draw(self: *AppState, ctx: vxfw.DrawContext) Allocator.Error!vxfw.Surface {
    //Menu
    const app_menu_surface: vxfw.SubSurface = .{
        //
        .origin = .{ .row = 0, .col = 0 },
        .surface = try self.app_menu.draw(ctx.withConstraints(ctx.min, .{ .width = ctx.max.width, .height = 1 })),
    };

    //app_status
    const app_status_surface: vxfw.SubSurface = .{
        //
        .origin = .{ .row = @intCast((ctx.max.height orelse 0) - 1), .col = 0 },
        .surface = try self.app_status.draw(ctx.withConstraints(ctx.min, .{ .width = ctx.max.width, .height = 1 })),
    };

    //database_list
    const database_list_surface: vxfw.SubSurface = .{
        //
        .origin = .{ .row = 1, .col = 0 },
        .surface = try self.database_list.draw(ctx.withConstraints(
            //
            ctx.min,
            //
            .{ .width = self.left_block_width, .height = self.database_height })),
    };

    // //table_list
    const table_height: u16 = @intCast((ctx.max.height orelse 0) - 2 - self.database_height);
    const table_list_surface: vxfw.SubSurface = .{
        //
        .origin = .{ .row = @intCast(self.database_height + 1), .col = 0 },
        .surface = try self.table_list.draw(ctx.withConstraints(ctx.min, .{ .width = self.left_block_width, .height = table_height })),
    };

    // //query_box
    const query_box_height: u16 = @intCast((ctx.max.height orelse 0) - 2 - self.result_height);
    const query_box_surface: vxfw.SubSurface = .{
        //
        .origin = .{ .row = 1, .col = @intCast(self.left_block_width) },
        .surface = try self.query_box.draw(ctx.withConstraints(ctx.min, .{
            //
            .width = @intCast((ctx.max.width orelse 0) - self.left_block_width),
            .height = query_box_height,
        })),
    };

    // //result_box
    const result_box_surface: vxfw.SubSurface = .{
        //
        .origin = .{ .row = @intCast(query_box_height + 1), .col = @intCast(self.left_block_width) },
        .surface = try self.result_box.draw(ctx.withConstraints(ctx.min, .{
            //
            .width = @intCast((ctx.max.width orelse 0) - self.left_block_width),
            .height = @intCast((ctx.max.height orelse 0) - query_box_height - 2),
        })),
    };

    const childs = try ctx.arena.alloc(vxfw.SubSurface, 6);

    childs[0] = app_menu_surface;
    childs[1] = app_status_surface;
    childs[2] = database_list_surface;
    childs[3] = table_list_surface;
    childs[4] = query_box_surface;
    childs[5] = result_box_surface;

    const surface = try vxfw.Surface.initWithChildren(
        //
        ctx.arena,
        self.widget(),
        ctx.max.size(),
        childs,
    );
    return surface;
}

pub fn widgetBuilder(ptr: *const anyopaque, idx: usize, _: usize) ?vxfw.Widget {
    const self: *const AppState = @ptrCast(@alignCast(ptr));
    if (idx >= self.filtered.items.len) return null;

    return self.filtered.items[idx].widget();
}
