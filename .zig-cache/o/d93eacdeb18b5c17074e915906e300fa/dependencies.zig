pub const packages = struct {
    pub const @"N-V-__8AACpFpwCXJZXXDaM9adUZOSdCSCy5dik1zsuZkk4x" = struct {
        pub const build_root = "C:\\Users\\arejano\\AppData\\Local\\zig\\p\\N-V-__8AACpFpwCXJZXXDaM9adUZOSdCSCy5dik1zsuZkk4x";
        pub const deps: []const struct { []const u8, []const u8 } = &.{};
    };
    pub const @"libs/libvaxis" = struct {
        pub const build_root = "c:\\projects\\zig\\shellter\\libs/libvaxis";
        pub const build_zig = @import("libs/libvaxis");
        pub const deps: []const struct { []const u8, []const u8 } = &.{
            .{ "zigimg", "zigimg-0.1.0-lly-O6N2EABOxke8dqyzCwhtUCAafqP35zC7wsZ4Ddxj" },
            .{ "zg", "zg-0.13.4-AAAAAGiZ7QLz4pvECFa_wG4O4TP4FLABHHbemH2KakWM" },
        };
    };
    pub const @"libs/zig-sqlite" = struct {
        pub const build_root = "c:\\projects\\zig\\shellter\\libs/zig-sqlite";
        pub const build_zig = @import("libs/zig-sqlite");
        pub const deps: []const struct { []const u8, []const u8 } = &.{
            .{ "sqlite", "N-V-__8AACpFpwCXJZXXDaM9adUZOSdCSCy5dik1zsuZkk4x" },
        };
    };
    pub const @"zg-0.13.4-AAAAAGiZ7QLz4pvECFa_wG4O4TP4FLABHHbemH2KakWM" = struct {
        pub const build_root = "C:\\Users\\arejano\\AppData\\Local\\zig\\p\\zg-0.13.4-AAAAAGiZ7QLz4pvECFa_wG4O4TP4FLABHHbemH2KakWM";
        pub const build_zig = @import("zg-0.13.4-AAAAAGiZ7QLz4pvECFa_wG4O4TP4FLABHHbemH2KakWM");
        pub const deps: []const struct { []const u8, []const u8 } = &.{
        };
    };
    pub const @"zigimg-0.1.0-lly-O6N2EABOxke8dqyzCwhtUCAafqP35zC7wsZ4Ddxj" = struct {
        pub const build_root = "C:\\Users\\arejano\\AppData\\Local\\zig\\p\\zigimg-0.1.0-lly-O6N2EABOxke8dqyzCwhtUCAafqP35zC7wsZ4Ddxj";
        pub const build_zig = @import("zigimg-0.1.0-lly-O6N2EABOxke8dqyzCwhtUCAafqP35zC7wsZ4Ddxj");
        pub const deps: []const struct { []const u8, []const u8 } = &.{
        };
    };
};

pub const root_deps: []const struct { []const u8, []const u8 } = &.{
    .{ "vaxis", "libs/libvaxis" },
    .{ "sqlite", "libs/zig-sqlite" },
};
