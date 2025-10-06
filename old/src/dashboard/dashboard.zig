const std = @import("std");
const log = std.debug.print;

//--vaxis
const vaxis = @import("vaxis");
const vxfw = vaxis.vxfw;

const Dashboard = @This();
const ui = @import("ui.zig");
const events = @import("handle_events.zig");

model: *Dashboard,
arena: std.heap.ArenaAllocator,
allocator: std.mem.Allocator,

//ui
title: []const u8 = "Dashboard",
fileTarget: []const u8 = "c:/projetos/teste.txt",
toggled: bool = false,

// state
mouse_down: bool = false,
has_mouse: bool = false,
focused: bool = false,

// Styles
style: struct {
    default: vaxis.Style = .{ .reverse = true },
    mouse_down: vaxis.Style = .{ .fg = .{ .index = 4 }, .reverse = true },
    hover: vaxis.Style = .{ .fg = .{ .index = 3 }, .reverse = true },
    focus: vaxis.Style = .{ .fg = .{ .index = 5 }, .reverse = true },
} = .{},

//actions
onClick: *const fn (?*anyopaque, mouse: vaxis.Mouse, ctx: *vxfw.EventContext) anyerror!void,
openFile: *const fn (?*anyopaque, ctx: *vxfw.EventContext) anyerror!void,

pub fn init(
    model: *Dashboard,
    allocator: std.mem.Allocator,
) !Dashboard {
    const arena = std.heap.ArenaAllocator.init(allocator);

    return .{
        .model = model,
        .allocator = allocator,
        .arena = arena,
        .onClick = click,
        .openFile = _openFile,
    };
}

fn readFile(allocator: std.mem.Allocator, path: []const u8) ![]u8 {
    var file = try std.fs.cwd().openFile(path, .{});
    defer file.close();
    return try file.readToEndAlloc(allocator, std.math.maxInt(usize));
}

pub fn deinit(self: *Dashboard) void {
    self.arena.deinit();
}

pub fn click(maybe_ptr: ?*anyopaque, mouse: vaxis.Mouse, _: *vxfw.EventContext) anyerror!void {
    log("Dashboard click, row:{d}, col:{d} \n", .{ mouse.row, mouse.col });
    const ptr = maybe_ptr orelse return;
    const self: *Dashboard = @ptrCast(@alignCast(ptr));

    if (self.toggled) {
        self.toggled = false;
        self.title = "Off";
    } else {
        self.toggled = true;
        self.title = "On";
    }
}

pub fn _openFile(maybe_ptr: ?*anyopaque, _: *vxfw.EventContext) anyerror!void {
    _ = maybe_ptr;
}

pub fn widget(self: *Dashboard) vxfw.Widget {
    return .{
        .userdata = self,
        .eventHandler = events.typeErasedEventHandler,
        .drawFn = ui.typeErasedDrawFn,
    };
}
