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

pub fn part2(allocator: std.mem.Allocator, input: []const u8) !u64 {
    var first = std.ArrayList(u32).init(allocator);
    defer first.deinit();
    var second = std.AutoHashMap(u32, u32).init(allocator);
    defer second.deinit();

    var it = std.mem.splitScalar(u8, input, '\n');
    while (it.next()) |line| {
        var ids = std.mem.tokenizeScalar(u8, line, ' ');
        if (ids.peek() == null) continue;
        const first_num = try std.fmt.parseInt(u32, ids.next().?, 10);
        try first.append(first_num);
        const second_num = try std.fmt.parseInt(u32, ids.next().?, 10);
        const entry = try second.getOrPut(second_num);
        if (entry.found_existing) {
            entry.value_ptr.* += 1;
        } else {
            entry.value_ptr.* = 1;
        }
    }
    var result: u32 = 0;
    for (first.items) |first_num| {
        if (second.get(first_num)) |ntimes| {
            result += first_num * ntimes;
        }
    }
    return result;
}

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    var file = try std.fs.cwd().openFile("inputs/day01.txt", .{});
    defer file.close();

    const input = try file.readToEndAlloc(allocator, std.math.maxInt(usize));

    const part1_result = try part1(allocator, input);
    std.debug.print("Part1 result is {}\n", .{part1_result});

    const part2_result = try part2(allocator, input);
    std.debug.print("Part2 result is {}\n", .{part2_result});
}

const test_input =
    \\3   4
    \\4   3
    \\2   5
    \\1   3
    \\3   9
    \\3   3
;

test "Part1" {
    try std.testing.expect(try part1(std.testing.allocator, test_input) == 11);
}

test "Part2" {
    try std.testing.expect(try part2(std.testing.allocator, test_input) == 31);
}
