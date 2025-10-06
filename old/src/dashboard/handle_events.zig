const std = @import("std");

//--vaxis
const vaxis = @import("vaxis");
const vxfw = vaxis.vxfw;
const Key = vaxis.Key;

//--model
const Dashboard = @import("dashboard.zig");

pub fn typeErasedEventHandler(ptr: *anyopaque, ctx: *vxfw.EventContext, event: vxfw.Event) anyerror!void {
    const self: *Dashboard = @ptrCast(@alignCast(ptr));
    return handleEvent(self, ctx, event);
}

fn handleEvent(self: *Dashboard, ctx: *vxfw.EventContext, event: vxfw.Event) anyerror!void {
    switch (event) {
        .key_press => |key| {
            if (key.matches('c', .{ .ctrl = true })) {
                ctx.quit = true;
                return;
            }

            if (key.matches(Key.tab, .{})) {
                return;
            }

            if (key.matches(Key.tab, .{ .shift = true })) {
                return;
            }

            if (key.matches(':', .{ .shift = true })) {}
        },
        .mouse => |mouse| {
            if (self.mouse_down and mouse.type == .release) {
                self.mouse_down = false;
                try self.onClick(self, mouse, ctx);
                return ctx.consumeAndRedraw();
            }
            if (mouse.type == .press and mouse.button == .left) {
                self.mouse_down = true;
                return ctx.consumeAndRedraw();
            }
            // return ctx.consumeEvent();
        },
        .mouse_enter => {
            // implicit redraw
            self.has_mouse = true;
            try ctx.setMouseShape(.pointer);
            return ctx.consumeAndRedraw();
        },
        .mouse_leave => {
            self.has_mouse = false;
            self.mouse_down = false;
            // implicit redraw
            try ctx.setMouseShape(.default);
        },
        .focus_in => {
            self.focused = true;
            ctx.redraw = true;
        },
        .focus_out => {
            self.focused = false;
            ctx.redraw = true;
        },
        else => {},
    }
}
