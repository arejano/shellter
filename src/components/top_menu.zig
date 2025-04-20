const std = @import("std");
const vaxis = @import("vaxis");
const vxfw = vaxis.vxfw;
const Allocator = std.mem.Allocator;
const ShellterApp = @import("../shellter.zig");
const Focus = ShellterApp.Focus;

const TopMenu = @This();

const Text = vxfw.Text;
const Center = vxfw.Center;

const AppStyles = @import("../styles.zig");

counter: u32 = 0,
userdata: ?*anyopaque = null,

has_mouse: bool = false,
mouse_down: bool = false,
mouse_up: bool = false,

//buttons
button_focus_left: vxfw.Button,
button_focus_right: vxfw.Button,

pub fn init(model: *ShellterApp) TopMenu {
    const bfl: vxfw.Button = .{
        .label = "F2:TASKS",
        .onClick = TopMenu.focusTask,
        .userdata = model,
    };

    const bfr: vxfw.Button = .{
        .label = "F3:FINANCE",
        .onClick = TopMenu.focusFinance,
        .userdata = model,
    };
    return .{
        .userdata = model,
        .button_focus_left = bfl,
        .button_focus_right = bfr,
    };
}

fn focusTask(maybe_ptr: ?*anyopaque, ctx: *vxfw.EventContext) anyerror!void {
    const ptr = maybe_ptr orelse return;
    const self: *ShellterApp = @ptrCast(@alignCast(ptr));
    self.feature_focus = .task;
    // try ctx.requestFocus(self.left_panel.widget());
    return ctx.consumeAndRedraw();
}

fn focusFinance(maybe_ptr: ?*anyopaque, ctx: *vxfw.EventContext) anyerror!void {
    const ptr = maybe_ptr orelse return;
    const self: *ShellterApp = @ptrCast(@alignCast(ptr));
    self.feature_focus = self.feature_focus.next();
    // try ctx.requestFocus(self.right_panel.widget());
    return ctx.consumeAndRedraw();
}

pub fn widget(self: *TopMenu) vxfw.Widget {
    return .{
        .userdata = @constCast(self),
        .eventHandler = typeErasedEventHandler,
        .drawFn = typeErasedDrawFn,
    };
}

fn typeErasedEventHandler(ptr: *anyopaque, ctx: *vxfw.EventContext, event: vxfw.Event) anyerror!void {
    const self: *TopMenu = @ptrCast(@alignCast(ptr));
    return self.handleEvent(ctx, event);
}

fn typeErasedDrawFn(ptr: *anyopaque, ctx: vxfw.DrawContext) Allocator.Error!vxfw.Surface {
    const self: *TopMenu = @ptrCast(@alignCast(ptr));
    return self.draw(ctx);
}

pub fn handleEvent(self: *TopMenu, ctx: *vxfw.EventContext, event: vxfw.Event) anyerror!void {
    switch (event) {
        .key_press => |key| {
            if (key.matches('a', .{ .ctrl = false })) {
                self.counter += 1;
                return;
            }
        },
        .mouse => |mouse| {
            if (self.mouse_down and mouse.type == .release) {
                self.mouse_down = false;
                self.has_mouse = !self.has_mouse;
                return ctx.consumeAndRedraw();
            }
            if (mouse.type == .press and mouse.button == .left) {
                self.mouse_down = true;
                return ctx.consumeAndRedraw();
            }
        },
        .focus_in => return ctx.requestFocus(self.widget()),
        .focus_out => {
            self.has_mouse = false;
            // self.has_mouse = false;
            // return ctx.consumeAndRedraw();
        },
        .mouse_enter => {
            // self.has_mouse = true;
            // try ctx.setMouseShape(.pointer);
            // return ctx.consumeAndRedraw();
        },
        .mouse_leave => {
            // self.has_mouse = false;
            // try ctx.setMouseShape(.default);
            // return ctx.consumeAndRedraw();
        },

        else => {},
    }
}

fn get_model(self: *TopMenu) *ShellterApp {
    const model: *ShellterApp = @ptrCast(@alignCast(self.userdata));
    return model;
}

pub fn draw(self: *TopMenu, ctx: vxfw.DrawContext) Allocator.Error!vxfw.Surface {
    const max_size = ctx.max.size();

    const bl_s: vxfw.SubSurface = .{
        //origin
        .origin = .{ .row = 0, .col = 0 },
        .surface = try self.button_focus_left.draw(ctx.withConstraints(ctx.min, .{ .width = @intCast(self.button_focus_left.label.len + 2), .height = 1 })),
    };

    const br_s: vxfw.SubSurface = .{
        //origin
        .origin = .{ .row = 0, .col = @intCast(self.button_focus_left.label.len + 3) },
        .surface = try self.button_focus_right.draw(ctx.withConstraints(ctx.min, .{ .width = @intCast(self.button_focus_right.label.len + 2), .height = 1 })),
    };

    const childs = try ctx.arena.alloc(vxfw.SubSurface, 2);
    childs[0] = bl_s;
    childs[1] = br_s;

    const surface = try vxfw.Surface.initWithChildren(
        //alloc
        ctx.arena,
        self.widget(),
        // ms,
        max_size,
        childs,
    );
    //Isso garante o background de outra cor
    @memset(surface.buffer, .{ .style = AppStyles.dark_background() });
    return surface;
}
