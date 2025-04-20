const std = @import("std");
const vaxis = @import("vaxis");
const vxfw = vaxis.vxfw;
const Allocator = std.mem.Allocator;
const AppStyles = @import("../styles.zig");
const Commons = @import("../components/commons.zig");
const TitleComponent = @import("../components/title.zig");

const Self = @This();

const ShellterApp = @import("../shellter.zig");
const ProjectItemStruct = ShellterApp.ProjectItemStruct;
const ProjectItemComponent = @import("../components/project_item.zig");

in_focus: bool = false,

title: TitleComponent = .{ .label = "Projects" },
item_focus: usize = 2,
options: [11][]const u8 = .{
    "Tarefa 1",
    "Teste 2",
    "Teste 3",
    "Teste 4",
    "Teste 4",
    "Teste 4",
    "Teste 4",
    "Teste 4",
    "Teste 4",
    "Teste 4",
    "Teste 4",
},

pub fn widget(self: *Self) vxfw.Widget {
    return .{
        .userdata = self,
        .eventHandler = typeErasedEventHandler,
        .drawFn = typeErasedDrawFn,
    };
}

pub fn next_item(self: *Self) void {
    if (self.item_focus == self.options.len) {
        self.item_focus = 1;
    } else {
        self.item_focus += 1;
    }
}

pub fn previous_item(self: *Self) void {
    if (self.item_focus == 1) {
        self.item_focus = self.options.len;
    } else {
        self.item_focus -= 1;
    }
}

fn typeErasedEventHandler(ptr: *anyopaque, ctx: *vxfw.EventContext, event: vxfw.Event) anyerror!void {
    const self: *Self = @ptrCast(@alignCast(ptr));
    return self.handleEvent(ctx, event);
}

fn typeErasedDrawFn(ptr: *anyopaque, ctx: vxfw.DrawContext) Allocator.Error!vxfw.Surface {
    const self: *Self = @ptrCast(@alignCast(ptr));
    return self.draw(ctx);
}

pub fn handleEvent(self: *Self, ctx: *vxfw.EventContext, event: vxfw.Event) anyerror!void {
    switch (event) {
        .key_press => |key| {
            if (key.matches('h', .{ .ctrl = false })) {
                return;
            }

            if (key.matches('j', .{ .ctrl = false })) {
                self.next_item();
                return ctx.consumeAndRedraw();
            }

            if (key.matches('k', .{ .ctrl = false })) {
                self.previous_item();
                return ctx.consumeAndRedraw();
            }

            if (key.matches('l', .{ .ctrl = false })) {
                return;
            }
        },
        .mouse => |mouse| {
            _ = mouse;
            // if (self.mouse_down and mouse.type == .release) {
            // self.mouse_down = false;
            // self.has_mouse = !self.has_mouse;
            // return ctx.consumeAndRedraw();
            // }
            // if (mouse.type == .press and mouse.button == .left) {
            // self.mouse_down = true;
            // return ctx.consumeAndRedraw();
            // }
        },
        .focus_in => {
            self.in_focus = true;
        },
        .focus_out => {
            // return ctx.consumeAndRedraw();
            self.in_focus = false;
        },
        .mouse_enter => {
            // self.in_focus = true;
            // return ctx.consumeAndRedraw();
        },
        .mouse_leave => {
            // self.in_focus = false;
            // return ctx.consumeAndRedraw();
        },

        else => {},
    }
}

pub fn draw(self: *Self, ctx: vxfw.DrawContext) Allocator.Error!vxfw.Surface {
    const max_size = ctx.max.size();
    const width = max_size.width;

    const cp_counter = self.options.len;
    const childs = try ctx.arena.alloc(vxfw.SubSurface, cp_counter);

    for (self.options, 0..) |opt, idx| {
        const pj: ProjectItemStruct = .{ .label = opt, .active_tasks = idx + 1, .selected = self.item_focus == idx + 1 };
        var pj_cp: ProjectItemComponent = .{ .project_item = pj };
        const sb: vxfw.SubSurface = .{ .origin = .{ .row = @intCast(idx), .col = 0 }, .surface = try pj_cp.draw(ctx.withConstraints(ctx.min, .{ .width = width, .height = 1 })) };
        childs[idx] = sb;
    }

    const surface = try vxfw.Surface.initWithChildren(
        //alloc
        ctx.arena,
        self.widget(),
        // ms,
        max_size,
        childs,
    );

    const style = if (self.in_focus) AppStyles.redBg() else AppStyles.dark_background();
    @memset(surface.buffer, .{ .style = style });
    return surface;
}
