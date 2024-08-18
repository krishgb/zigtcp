// ***** Get CPU Statistics *****
//     - Number of Cores: 4
//     - CPU Model: Intel Core i7
//     - CPU Usage: 25%
//

const std = @import("std");

pub fn cpuinfo(allocator: std.mem.Allocator) ![]u8 {
    const page_alloc = std.heap.page_allocator;

    var cores: u8 = 0;
    var model_name = try page_alloc.alloc(u8, 100);
    defer page_alloc.free(model_name);
    var usage: f32 = 0;

    // Read `/proc/cpuinfo` to get cores and model name
    const cpuinfo_file = try std.fs.openFileAbsolute("/proc/cpuinfo", .{ .mode = .read_only });
    defer cpuinfo_file.close();

    var reader = cpuinfo_file.reader();
    var file_buf = [_]u8{0} ** 1024;
    while (try reader.readUntilDelimiterOrEof(&file_buf, '\n')) |line| {
        var splitted = std.mem.split(u8, line, ":");

        const first = splitted.first()[0..];
        // Number of cores
        if (std.mem.eql(u8, first, "cpu cores\t")) {
            cores += 1;
        }

        // CPU Model
        if (std.mem.eql(u8, first, "model name\t")) {
            const model = std.mem.trim(u8, splitted.next().?, " ");

            // std.mem.copyForwards(u8, model_name, model);
            for (model, 0..) |char, i| {
                model_name[i] = char;
            }
            model_name = model_name[0..model.len];
        }
    }

    // Read `/proc/stat` to get cpu usage
    var prev_total: f32 = 0;
    var prev_idle: f32 = 0;
    var usage_arr = [_]f32{0} ** 5;
    for (0..usage_arr.len) |i| {
        const stat_file = try std.fs.openFileAbsolute("/proc/stat", .{ .mode = .read_only });
        defer stat_file.close();

        const content = try stat_file.reader().readUntilDelimiter(&file_buf, '\n');
        var splitted = std.mem.split(u8, content, " ");

        _ = splitted.next().?;
        _ = splitted.next().?;

        var total: f32 = 0;
        var idle: f32 = 0;
        var idle_index: f32 = 0;
        while (splitted.next()) |l| {
            const t = try std.fmt.parseFloat(f32, l);
            total += t;
            idle_index += 1;

            if (idle_index == 4) {
                idle = t;
            }
        }

        usage_arr[i] = (1 - (idle - prev_idle) / (total - prev_total)) * 100;
        prev_total = total;
        prev_idle = idle;

        std.time.sleep(100 * std.time.ns_per_ms);
    }

    var total_usage: f32 = 0;
    for (usage_arr) |i| {
        total_usage += i;
    }
    usage = total_usage / usage_arr.len;
    return try std.fmt.allocPrint(allocator, "\nNumber of Cores : {}\nCPU Model : {s}\nCPU Usage : {d:.2}%\n", .{ cores, model_name, usage });
}
