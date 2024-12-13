const std = @import("std");
const Allocator = std.mem.Allocator;
const parseNumbers = @import("utils.zig").parseNumbers;

fn valid(level: []const i8) bool {
    var increasing = false;
    var decreasing = false;
    for (0..level.len - 1) |i| {
        const diff = level[i + 1] - level[i];
        if (diff > 0) increasing = true else decreasing = true;
        const dis = @abs(diff);
        if (dis <= 0 or dis > 3 or increasing and decreasing) return false;
    }
    return true;
}
pub fn part1(allocator: Allocator, input: []const u8) !u32 {
    var result: u32 = 0;

    var it = std.mem.tokenizeScalar(u8, input, '\n');
    while (it.next()) |line| {
        const level = try parseNumbers(i8, allocator, line, " ");
        defer allocator.free(level);
        if (valid(level)) result += 1;
    }
    return result;
}

pub fn part2(allocator: Allocator, input: []const u8) !u32 {
    var result: u32 = 0;

    var it = std.mem.tokenizeScalar(u8, input, '\n');
    while (it.next()) |line| {
        const level = try parseNumbers(i8, allocator, line, " ");
        var level2 = try allocator.alloc(i8, level.len - 1);
        defer {
            allocator.free(level);
            allocator.free(level2);
        }
        if (valid(level)) {
            result += 1;
            continue;
        }
        for (0..level.len) |i| {
            @memcpy(level2[0..i], level[0..i]);
            @memcpy(level2[i..], level[i + 1 ..]);
            if (valid(level2)) {
                result += 1;
                break;
            }
        }
    }
    return result;
}

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();

    var file = try std.fs.cwd().openFile("inputs/day02.txt", .{});
    defer file.close();

    const input = try file.readToEndAlloc(allocator, std.math.maxInt(usize));

    std.debug.print("Part1 result is {}\n", .{try part1(allocator, input)});
    std.debug.print("Part2 result is {}\n", .{try part2(allocator, input)});
}

const test_input =
    \\7 6 4 2 1
    \\1 2 7 8 9
    \\9 7 6 2 1
    \\1 3 2 4 5
    \\8 6 4 4 1
    \\1 3 6 7 9
;

test "Part1 test" {
    try std.testing.expect(try part1(std.testing.allocator, test_input) == 2);
}
test "Part2 test" {
    try std.testing.expect(try part2(std.testing.allocator, test_input) == 4);
}
