const std = @import("std");

pub fn part1(input: []const u8) !u32 {
    var result: u32 = 0;
    var it = std.mem.window(u8, input, 4, 1);
    var i: i32 = -1;
    while (it.next()) |win| {
        i += 1;
        if (std.mem.eql(u8, win, "mul(")) {
            const comma_pos = std.mem.indexOfScalarPos(u8, input, @intCast(i), ',') orelse continue;
            const first = std.fmt.parseInt(u32, input[@intCast(i + 4)..comma_pos], 10) catch continue;
            const paren_pos = std.mem.indexOfScalarPos(u8, input, @intCast(i), ')') orelse continue;

            const second = std.fmt.parseInt(u32, input[comma_pos + @as(usize, 1) .. paren_pos], 10) catch continue;

            result += first * second;
        }
    }
    return result;
}

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();

    const file = try std.fs.cwd().openFile("inputs/day03.txt", .{});
    defer file.close();
    const input = try file.readToEndAlloc(allocator, std.math.maxInt(usize));
    std.debug.print("Part 1 result: {}\n", .{try part1(input)});
}

const test_input = "xmul(2,4)%&mul[3,7]!@^do_not_mul(5,5)+mul(32,64]then(mul(11,8)mul(8,5))";

test "Part 1" {
    try std.testing.expect(try part1(test_input) == 161);
}
