const std = @import("std");
const parseNumbers = @import("utils.zig").parseNumbers;
const Allocator = std.mem.Allocator;

pub fn part1(allocator: Allocator, input: []const u8) !u32 {
    var first = std.ArrayList(u32).init(allocator);
    var second = std.ArrayList(u32).init(allocator);
    defer {
        first.deinit();
        second.deinit();
    }

    var it = std.mem.tokenizeScalar(u8, input, '\n');
    while (it.next()) |line| {
        const nums = try parseNumbers(u32, allocator, line, " ");
        defer allocator.free(nums);

        try first.append(nums[0]);
        try second.append(nums[1]);
    }

    std.mem.sort(u32, first.items, {}, comptime std.sort.asc(u32));
    std.mem.sort(u32, second.items, {}, comptime std.sort.asc(u32));

    var result: u32 = 0;
    for (first.items, second.items) |first_num, second_num| {
        result += if (first_num > second_num) first_num - second_num else second_num - first_num;
    }

    return result;
}

pub fn part2(allocator: Allocator, input: []const u8) !u32 {
    var first = std.ArrayList(u32).init(allocator);
    var second = std.AutoHashMap(u32, u32).init(allocator);
    defer {
        first.deinit();
        second.deinit();
    }

    var it = std.mem.tokenizeScalar(u8, input, '\n');
    while (it.next()) |line| {
        const nums = try parseNumbers(u32, allocator, line, " ");
        defer allocator.free(nums);

        try first.append(nums[0]);
        const entry = try second.getOrPut(nums[1]);
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

    const file = try std.fs.cwd().openFile("inputs/day01.txt", .{});
    defer file.close();

    const input = try file.readToEndAlloc(allocator, std.math.maxInt(usize));

    std.debug.print("Part1 result is {}\n", .{try part1(allocator, input)});
    std.debug.print("Part2 result is {}\n", .{try part2(allocator, input)});
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
