const std = @import("std");

pub fn main() !void {
    std.debug.print("Hello world", .{});
}

test "Un test" {
    try std.testing.expect(false);
}
