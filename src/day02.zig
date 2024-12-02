const std = @import("std");

const Type = enum {
    increasing,
    decreasing,
};

pub fn part1(input: []const u8) !u32 {
    var result: u32 = 0;
    var it = std.mem.splitScalar(u8, input, '\n');
    outer: while (it.next()) |line| {
        if (line.len == 0) continue;
        var levels = std.mem.splitScalar(u8, line, ' ');
        const first = try std.fmt.parseInt(u32, levels.next().?, 10);
        var tmp = try std.fmt.parseInt(u32, levels.next().?, 10);

        const dis = if (first > tmp) first - tmp else tmp - first;
        if (dis == 0 or dis > 3) {
            continue;
        }
        const variation: Type = if (first < tmp) .increasing else .decreasing;
        while (levels.next()) |level| {
            const num = try std.fmt.parseInt(u32, level, 10);
            if (variation == .increasing and num < tmp or variation == .decreasing and num > tmp) {
                continue :outer;
            }
            const dis2 = if (num > tmp) num - tmp else tmp - num;
            if (dis2 == 0 or dis2 > 3) {
                continue :outer;
            }
            tmp = num;
        }
        result += 1;
    }
    return result;
}

fn validLevel(level: []u32) bool {
    const variance: Type = if (level[0] < level[1]) .increasing else .decreasing;
    for (0..level.len - 1) |i| {
        if (variance == .increasing and level[i] > level[i + 1] or variance == .decreasing and level[i] < level[i + 1]) {
            return false;
        }
        const dis = if (level[i] > level[i + 1]) level[i] - level[i + 1] else level[i + 1] - level[i];
        if (dis == 0 or dis > 3) {
            return false;
        }
    }
    return true;
}

pub fn part2(input: []const u8) !u32 {
    var result: u32 = 0;
    var it = std.mem.tokenizeScalar(u8, input, '\n');

    while (it.next()) |line| {
        var nums: [10]u32 = undefined;
        var nums2: [10]u32 = undefined;
        var j: u8 = 0;
        var level = std.mem.splitScalar(u8, line, ' ');
        while (level.next()) |n| {
            nums[j] = try std.fmt.parseInt(u32, n, 10);
            j += 1;
        }
        if (validLevel(nums[0..j])) {
            result += 1;
            continue;
        }
        for (0..j + 1) |n| {
            std.mem.copyForwards(u32, &nums2, nums[0..n]);
            std.mem.copyForwards(u32, nums2[n..], nums[n + 1 ..]);
            if (validLevel(nums2[0 .. j - 1])) {
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

    const part1_result = try part1(input);
    std.debug.print("Part1 result is {}\n", .{part1_result});

    const part2_result = try part2(input);
    std.debug.print("Part2 result is {}\n", .{part2_result});
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
    try std.testing.expect(try part1(test_input) == 2);
}
test "Part2 test" {
    try std.testing.expect(try part2(test_input) == 4);
}
