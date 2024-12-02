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

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();

    var file = try std.fs.cwd().openFile("inputs/day02.txt", .{});
    defer file.close();

    const input = try file.readToEndAlloc(allocator, std.math.maxInt(usize));

    const part1_result = try part1(input);
    std.debug.print("Part1 result is {}\n", .{part1_result});
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
