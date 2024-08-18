const std = @import("std");
const Config = @import("config.zig").Config;
const TCP = @import("tcp.zig").TCP;

fn accept(stream: *std.net.Stream) void {
    _ = stream.write("<h1>Hello World</h1>\n") catch 0;
    stream.close();
}

pub fn main() !void {
    const config = try Config.init(std.heap.page_allocator);

    const tcp_connection = try TCP.init(config.address, config.port);
    var server = try tcp_connection.addr.listen(.{});
    defer server.deinit();

    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const gpa_allocator = gpa.allocator();

    std.log.info("Server running on port {} with {} threads.", .{ config.port, config.threads });

    var connection: std.net.Server.Connection = undefined;
    defer connection.stream.close();

    while (true) {
        connection = try server.accept();

        const thread = try std.Thread.spawn(.{ .allocator = gpa_allocator }, accept, .{&connection.stream});
        defer thread.join();
    }
    connection.stream.close();
}
