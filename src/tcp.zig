const std = @import("std");

const net = std.net;

pub const TCP = struct {
    addr: net.Address,
    stream: net.Stream,

    const socket_type = std.posix.SOCK.STREAM;
    const protocol = std.posix.IPPROTO.TCP;

    pub fn init(address: [4]u8, port: u16) !TCP {
        const addr = net.Address.initIp4(address, port);
        const socket = try std.posix.socket(addr.any.family, socket_type, protocol);
        const stream = net.Stream{ .handle = socket };
        defer stream.close();

        return .{
            .addr = addr,
            .stream = stream,
        };
    }
};
