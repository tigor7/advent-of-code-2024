const std = @import("std");

pub fn part1(allocator: std.mem.Allocator, input: []const u8) !u64 {
    var it = std.mem.splitScalar(u8, input, '\n');
    var first = std.ArrayList(u32).init(allocator);
    defer first.deinit();
    var second = std.ArrayList(u32).init(allocator);
    defer second.deinit();

    while (it.next()) |line| {
        var ids = std.mem.tokenizeScalar(u8, line, ' ');
        if (ids.peek() == null) continue;
        const first_num = try std.fmt.parseInt(u32, ids.next().?, 10);
        const second_num = try std.fmt.parseInt(u32, ids.next().?, 10);
        try first.append(first_num);
        try second.append(second_num);
    }
    std.mem.sort(u32, first.items, {}, comptime std.sort.asc(u32));
    std.mem.sort(u32, second.items, {}, comptime std.sort.asc(u32));

    var result: u32 = 0;
    for (first.items, second.items) |first_num, second_num| {
        result += if (first_num > second_num) first_num - second_num else second_num - first_num;
    }

    return result;
}

pub fn part2() u64 {}

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    var file = try std.fs.cwd().openFile("inputs/day01.txt", .{});
    defer file.close();

    const input = try file.readToEndAlloc(allocator, std.math.maxInt(usize));
    const part1_result = try part1(allocator, input);
    std.debug.print("Part1 result is {}\n", .{part1_result});
}

test "Part1" {
    const input =
        \\3   4
        \\4   3
        \\2   5
        \\1   3
        \\3   9
        \\3   3
    ;
    try std.testing.expect(try part1(std.testing.allocator, input) == 11);
}
