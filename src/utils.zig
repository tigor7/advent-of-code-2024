const std = @import("std");
const Allocator = std.mem.Allocator;

pub fn parseNumbers(comptime T: type, allocator: Allocator, str: []const u8, seps: []const u8) ![]T {
    var list = std.ArrayList(T).init(allocator);

    var it = std.mem.tokenizeAny(u8, str, seps);
    while (it.next()) |raw| {
        const num = try std.fmt.parseInt(T, raw, 10);
        try list.append(num);
    }
    return list.toOwnedSlice();
}
