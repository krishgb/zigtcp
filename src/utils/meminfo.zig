// 2.  ### `Get Memory Statistics`
//     - Total Memory: 8192 MB
//     - Used Memory: 4096 MB
//     - Free Memory: 4096 MB
//     - Memory Type: DDR4

const std = @import("std");

pub fn meminfo(allocator: std.mem.Allocator) ![]u8 {
    var total_memory: f32 = 0;
    var free_memory: f32 = 0;
    var used_memory: f32 = 0;

    const file = try std.fs.openFileAbsolute("/proc/meminfo", .{ .mode = .read_only });
    defer file.close();

    var buf: [512]u8 = undefined;
    for (0..2) |_| {
        _ = try file.reader().readUntilDelimiter(&buf, '\n');

        var splitted = std.mem.splitScalar(u8, &buf, ':');
        const token = splitted.first();

        const trimmed = std.mem.trim(u8, splitted.next().?, " ");
        var split_mem_size = std.mem.split(u8, trimmed, " ");

        if (std.mem.eql(u8, token, "MemTotal")) {
            total_memory = try std.fmt.parseFloat(f32, split_mem_size.first()) / 1000;
        }

        if (std.mem.eql(u8, token, "MemFree")) {
            free_memory = try std.fmt.parseFloat(f32, split_mem_size.first()) / 1000;
        }
    }

    used_memory = total_memory - free_memory;

    return try std.fmt.allocPrint(allocator, "Total Memory : {d:.2} MB\nUsed Memory: {d:.2} MB\nFree Memory : {d:.2} MB\n", .{ total_memory, used_memory, free_memory });
}
