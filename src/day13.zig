const std = @import("std");
const parseNumbers = @import("utils.zig").parseNumbers;
const Allocator = std.mem.Allocator;

pub fn part1(allocator: Allocator, input: []const u8) !u64 {
    var result: u64 = 0;
    var it = std.mem.splitSequence(u8, input, "\n");
    while (it.next()) |line| {
        if (line.len == 0) continue;
        const a_nums = try parseNumbers(i64, allocator, line, "Button A:XY+,");
        const b_nums = try parseNumbers(i64, allocator, it.next().?, "Button B:XY+,");
        const prize_nums = try parseNumbers(i64, allocator, it.next().?, "Prize: XY=,");
        defer {
            allocator.free(a_nums);
            allocator.free(b_nums);
            allocator.free(prize_nums);
        }
        const det = a_nums[0] * b_nums[1] - a_nums[1] * b_nums[0];

        const A = @divTrunc(prize_nums[0] * b_nums[1] - prize_nums[1] * b_nums[0], det);
        const B = @divTrunc(a_nums[0] * prize_nums[1] - a_nums[1] * prize_nums[0], det);
        if (A * a_nums[0] + B * b_nums[0] == prize_nums[0] and A * a_nums[1] + B * b_nums[1] == prize_nums[1]) {
            result += @intCast(A * 3 + B);
        }
    }
    return result;
}

pub fn part2(allocator: Allocator, input: []const u8) !u64 {
    var result: u64 = 0;
    var it = std.mem.splitSequence(u8, input, "\n");
    while (it.next()) |line| {
        if (line.len == 0) continue;
        const a_nums = try parseNumbers(i64, allocator, line, "Button A:XY+,");
        const b_nums = try parseNumbers(i64, allocator, it.next().?, "Button B:XY+,");
        const prize_nums = try parseNumbers(i64, allocator, it.next().?, "Prize: XY=,");
        prize_nums[0] += 10000000000000;
        prize_nums[1] += 10000000000000;
        defer {
            allocator.free(a_nums);
            allocator.free(b_nums);
            allocator.free(prize_nums);
        }
        const det = a_nums[0] * b_nums[1] - a_nums[1] * b_nums[0];

        const A = @divTrunc(prize_nums[0] * b_nums[1] - prize_nums[1] * b_nums[0], det);
        const B = @divTrunc(a_nums[0] * prize_nums[1] - a_nums[1] * prize_nums[0], det);
        if (A * a_nums[0] + B * b_nums[0] == prize_nums[0] and A * a_nums[1] + B * b_nums[1] == prize_nums[1]) {
            result += @intCast(A * 3 + B);
        }
    }
    return result;
}
pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();

    const file = try std.fs.cwd().openFile("inputs/day13.txt", .{});
    defer file.close();
    const input = try file.readToEndAlloc(allocator, std.math.maxInt(usize));

    std.debug.print("Part1 result: {}\n", .{try part1(allocator, input)});
    std.debug.print("Part2 result: {}\n", .{try part2(allocator, input)});
}

const test_input =
    \\Button A: X+94, Y+34
    \\Button B: X+22, Y+67
    \\Prize: X=8400, Y=5400
    \\
    \\Button A: X+26, Y+66
    \\Button B: X+67, Y+21
    \\Prize: X=12748, Y=12176
    \\
    \\Button A: X+17, Y+86
    \\Button B: X+84, Y+37
    \\Prize: X=7870, Y=6450
    \\
    \\Button A: X+69, Y+23
    \\Button B: X+27, Y+71
    \\Prize: X=18641, Y=10279
;

test "Part 1 test" {
    try std.testing.expect(try part1(std.testing.allocator, test_input) == 480);
}
