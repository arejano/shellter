const vaxis = @import("vaxis");
const vxfw = vaxis.vxfw;
const std = @import("std");
const Allocator = std.mem.Allocator;
const Text = vxfw.Text;
const Key = vaxis.Key;

const Mode = enum { Command, Navigate };

const Taskmaster = @This();

style: struct {
    default: vaxis.Style = .{ .reverse = true },
    new_label: vaxis.Style = .{ .fg = .{ .index = 4 }, .reverse = true },
    mouse_down: vaxis.Style = .{ .fg = .{ .index = 4 }, .reverse = true },
    hover: vaxis.Style = .{ .fg = .{ .index = 3 }, .reverse = true },
    focus: vaxis.Style = .{ .fg = .{ .index = 5 }, .reverse = true },
} = .{},

mode: Mode = .Navigate,
allocator: std.mem.Allocator,
arena: std.heap.ArenaAllocator,
userdata: ?*anyopaque,
app: *vxfw.App,
text: []const u8,

task_list: std.ArrayList(vxfw.Text),

//Elements
command_input: vxfw.TextField,
list_view: vxfw.ListView,
unicode_data: *const vaxis.Unicode,

pub fn init(
    model: *Taskmaster,
    app: *vxfw.App,
    allocator: Allocator,
) Taskmaster {
    const vx_app: *vxfw.App = @ptrCast(@alignCast(app));
    const arena = std.heap.ArenaAllocator.init(allocator);

    const task_list = std.ArrayList(vxfw.Text).init(allocator);

    return .{
        .unicode_data = &app.vx.unicode,
        .allocator = allocator,
        .userdata = model,
        .app = vx_app,
        .task_list = task_list,
        .arena = arena,
        //elements
        .command_input = .{
            .buf = vxfw.TextField.Buffer.init(allocator),
            .unicode = &app.vx.unicode,
            .userdata = model,
            .onChange = Taskmaster.onChangeInput,
            .onSubmit = Taskmaster.onSubmitInput,
        },
        .list_view = .{
            .children = .{
                .builder = .{
                    .userdata = model,
                    .buildFn = Taskmaster.listWidgetBuilder,
                },
            },
            .item_count = 0,
        },
        .text = "",
    };
}
fn onChangeInput(maybe_ptr: ?*anyopaque, _: *vxfw.EventContext, str: []const u8) anyerror!void {
    const ptr = maybe_ptr orelse return;
    const self: *Taskmaster = @ptrCast(@alignCast(ptr));
    _ = self;
    _ = str;
    // self.text = str;
}

fn onSubmitInput(maybe_ptr: ?*anyopaque, ctx: *vxfw.EventContext, str: []const u8) anyerror!void {
    const ptr = maybe_ptr orelse return;
    const self: *Taskmaster = @ptrCast(@alignCast(ptr));

    // Fazer uma cópia da string para garantir que ela permanece válida
    const owned_str = try self.allocator.dupe(u8, str);
    const text_widget = vxfw.Text{ .text = owned_str };
    try self.task_list.append(text_widget);

    // Atualizar o item_count do ListView e forçar redraw
    self.list_view.item_count = @intCast(self.task_list.items.len);
    ctx.consumeAndRedraw();
}

fn listWidgetBuilder(ptr: *const anyopaque, idx: usize, _: usize) ?vxfw.Widget {
    const self: *Taskmaster = @ptrCast(@constCast(@alignCast(ptr)));

    if (idx >= self.task_list.items.len) {
        return null;
    }

    return self.task_list.items[idx].widget();
}

fn typeErasedEventHandler(ptr: *anyopaque, ctx: *vxfw.EventContext, event: vxfw.Event) anyerror!void {
    const self: *Taskmaster = @ptrCast(@alignCast(ptr));
    return self.handleEvent(ctx, event);
}

fn typeErasedDrawFn(ptr: *anyopaque, ctx: vxfw.DrawContext) Allocator.Error!vxfw.Surface {
    const self: *Taskmaster = @ptrCast(@alignCast(ptr));
    return self.draw(ctx);
}

pub fn handleEvent(self: *Taskmaster, ctx: *vxfw.EventContext, event: vxfw.Event) anyerror!void {
    switch (event) {
        .init => {
            // try ctx.requestFocus(self.command_input.widget());
            std.log.info("Teste", .{});
        },
        .key_press => |key| {
            if (key.matches('c', .{ .ctrl = true })) {
                ctx.quit = true;
                return;
            }

            if (key.matches(Key.tab, .{})) {
                try ctx.requestFocus(self.list_view.widget());
                std.log.info("ListView Focus", .{});
                return;
            }

            if (key.matches(Key.tab, .{ .shift = true })) {
                try ctx.requestFocus(self.command_input.widget());
                std.log.info("CommandInput Focus", .{});
                return;
            }

            if (key.matches(':', .{ .shift = true })) {
                self.mode = .Command;
                try ctx.requestFocus(self.command_input.widget());
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
    const self: *Taskmaster = @ptrCast(@alignCast(ptr));
    _ = self;
    return ctx.consumeAndRedraw();
}

pub fn deinit(self: *Taskmaster) void {
    // Liberar todas as strings alocadas
    for (self.task_list.items) |item| {
        self.allocator.free(item.text);
    }
    self.task_list.deinit();

    // Limpar o TextField adequadamente
    self.command_input.deinit();

    self.arena.deinit();
}

pub fn widget(self: *Taskmaster) vxfw.Widget {
    return .{
        .userdata = self,
        .eventHandler = typeErasedEventHandler,
        .drawFn = typeErasedDrawFn,
    };
}

pub fn getStatusLabel(self: *Taskmaster) []const u8 {
    const label = switch (self.mode) {
        .Command => "Command:",
        .Navigate => "N:",
    };

    return label;
}

pub fn draw(self: *Taskmaster, ctx: vxfw.DrawContext) Allocator.Error!vxfw.Surface {
    const counter_label = try std.fmt.allocPrint(ctx.arena, "{}", .{self.task_list.items.len});
    const counter_text: vxfw.Text = .{ .text = counter_label };

    const counter_surface: vxfw.SubSurface = .{
        .origin = .{ .row = (ctx.max.height orelse 0) - 1, .col = (ctx.max.width orelse 0) - 4 },
        .surface = try counter_text.draw(ctx.withConstraints(ctx.min, .{ .width = ctx.max.width, .height = 1 })),
    };

    const list_surface: vxfw.SubSurface = .{
        .origin = .{ .row = 1, .col = 0 },
        .surface = try self.list_view.draw(ctx.withConstraints(ctx.min, .{ .width = ctx.max.width, .height = (ctx.max.height orelse 0) - 3 })),
    };

    const status_label = self.getStatusLabel();
    const text: vxfw.Text = .{ .style = self.style.new_label, .text = status_label };

    const text_surface: vxfw.SubSurface = .{
        .origin = .{ .row = (ctx.max.height orelse 0) - 2, .col = 0 },
        .surface = try text.draw(ctx.withConstraints(ctx.min, .{ .width = @intCast(status_label.len), .height = 1 })),
    };

    const input_surface: vxfw.SubSurface = .{
        .origin = .{ .row = (ctx.max.height orelse 0) - 2, .col = @intCast(status_label.len) },
        .surface = try self.command_input.draw(ctx.withConstraints(ctx.min, .{ .width = (ctx.max.width orelse 0) - @as(u16, @intCast(status_label.len)), .height = 1 })),
    };

    const childs = try ctx.arena.alloc(vxfw.SubSurface, 4);
    childs[0] = counter_surface;
    childs[1] = list_surface;
    childs[2] = text_surface;
    childs[3] = input_surface;

    const surface = try vxfw.Surface.initWithChildren(
        ctx.arena,
        self.widget(),
        ctx.max.size(),
        childs,
    );
    return surface;
}
