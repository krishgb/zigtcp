const std = @import("std");
const Allocator = std.mem.Allocator;

pub const Config = struct {
    address: [4]u8,
    port: u16,
    threads: u8,

    pub fn init(allocator: Allocator) !Config {
        const args = try std.process.argsAlloc(allocator);
        defer std.process.argsFree(allocator, args);

        std.debug.assert(args.len > 1);

        const port: u16 = try std.fmt.parseInt(u16, args[1], 10);

        var threads: u8 = 2;
        if (args.len > 2)
            threads = try std.fmt.parseInt(u8, args[2], 10);

        return Config{
            .address = [4]u8{ 0, 0, 0, 0 },
            .port = port,
            .threads = threads,
        };
    }
};
