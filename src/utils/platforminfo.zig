//  ### `Get Platform Details`
//  - Cloud Platform: OpenStack
//  - Kernel Version: 5.4.0
//  - Architecture: x86_64
//  - Hypervisor: KVM
//  - Instance Type: Virtual Machine

const std = @import("std");
const c = @cImport({
    @cInclude("sys/utsname.h");
});

pub fn platforminfo(allocator: std.mem.Allocator) ![]u8 {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer std.debug.assert(gpa.deinit() == .ok);

    var alloc = gpa.allocator();

    var mach: c.struct_utsname = undefined;

    var platform: []u8 = undefined;
    defer alloc.free(platform);

    var arch: []u8 = undefined;
    defer alloc.free(arch);

    var kernel_version: []u8 = undefined;
    defer alloc.free(kernel_version);

    // WIP
    const hypervisor: []const u8 = "";
    const instance: []const u8 = "";

    if (c.uname(&mach) == 0) {
        platform = try alloc.dupe(u8, mach.nodename[0..]);
        arch = try alloc.dupe(u8, mach.machine[0..]);
        kernel_version = try alloc.dupe(u8, mach.version[0..]);
    }
    return try std.fmt.allocPrint(allocator, "Cloud Platform\t:\t{s}\nKernel Version\t:\t{s}\nArchitecture\t:\t{s}\nHypervisor\t:\t{s}\nInstance Type\t:\t{s}\n", .{ platform, kernel_version, arch, hypervisor, instance });
}
