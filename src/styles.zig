const vaxis = @import("vaxis");

pub const left_panel_size: usize = 32;

const AppStyles = @This();

pub fn default() vaxis.Style {
    const def: vaxis.Style = .{ .reverse = false };
    return def;
}

pub fn redBg() vaxis.Style {
    const def: vaxis.Style = .{ .bg = .{ .rgb = .{ 255, 0, 0 } } };
    return def;
}

pub fn dark_background() vaxis.Style {
    const def: vaxis.Style = .{ .bg = .{ .rgb = .{ 17, 17, 27 } } };
    return def;
}

pub fn dark_bg_text() vaxis.Style {
    const def: vaxis.Style = .{ .bg = .{ .rgb = .{ 17, 17, 27 } } };
    return def;
}

pub fn panel_name_dark() vaxis.Style {
    const def: vaxis.Style = .{
        //fg
        .fg = .{ .rgb = .{ 255, 255, 255 } },
        //bg
        .bg = .{ .rgb = .{ 17, 17, 27 } },
    };
    return def;
}

pub fn panel_name_dark_active() vaxis.Style {
    const def: vaxis.Style = .{
        //fg
        .fg = .{ .rgb = .{ 0, 0, 0 } },
        //bg
        .bg = .{ .rgb = .{ 203, 166, 247 } },
    };
    return def;
}

pub fn panel_name_light() vaxis.Style {
    const def: vaxis.Style = .{ .bg = .{ .rgb = .{ 17, 17, 27 } } };
    return def;
}

pub fn panel_name_light_active() vaxis.Style {
    const def: vaxis.Style = .{ .bg = .{ .rgb = .{ 17, 17, 27 } } };
    return def;
}

pub fn status_title() vaxis.Style {
    const def: vaxis.Style = .{
        //
        .fg = .{ .rgb = .{ 0, 0, 0 } },
        //bg
        .bg = .{ .rgb = .{ 203, 166, 247 } },
    };
    return def;
}
