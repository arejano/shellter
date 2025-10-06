const std = @import("std");
const Allocator = std.mem.Allocator;

const MenuItem = struct {
    label: []const u8,
};

pub const AppData = struct {
    allocator: std.mem.Allocator,
    menus: std.array_list.Managed(MenuItem),

    pub fn init(allocator: Allocator) !AppData {
        const menus = try buildMenus(allocator);
        return .{
            .allocator = allocator,
            .menus = menus,
        };
    }

    pub fn deinit(self: *AppData) void {
        self.menus.deinit();
    }

    pub fn buildMenus(allocator: Allocator) Allocator.Error!std.array_list.Managed(MenuItem) {
        var menus = std.array_list.Managed(MenuItem).init(allocator);
        try menus.append(.{ .label = "Agents" });
        try menus.append(.{ .label = "Config" });
        return menus;
    }
};
