const std = @import("std");
const parseNumbers = @import("utils.zig").parseNumbers;
const Allocator = std.mem.Allocator;

const Robot = struct {
    x: i32,
    y: i32,
    v_x: i32,
    v_y: i32,
};

pub fn part1(allocator: Allocator, input: []const u8, width: i32, height: i32) !u64 {
    var robots = std.ArrayList(Robot).init(allocator);
    defer robots.deinit();

    var it = std.mem.tokenizeScalar(u8, input, '\n');
    while (it.next()) |line| {
        const nums = try parseNumbers(i32, allocator, line, "pv=, ");
        defer allocator.free(nums);
        try robots.append(.{ .x = nums[0], .y = nums[1], .v_x = nums[2], .v_y = nums[3] });
    }

    for (0..100) |_| {
        for (robots.items) |*robot| {
            robot.x = @mod(robot.x + robot.v_x, width);
            robot.y = @mod(robot.y + robot.v_y, height);
        }
    }
    const middle_x: i32 = @divTrunc(width, 2);
    const middle_y: i32 = @divTrunc(height, 2);
    var first: u32 = 0;
    var second: u32 = 0;
    var third: u32 = 0;
    var fourth: u32 = 0;

    for (robots.items) |robot| {
        if (robot.x < middle_x and robot.y < middle_y) {
            first += 1;
        } else if (robot.x > middle_x and robot.y < middle_y) {
            second += 1;
        } else if (robot.x < middle_x and robot.y > middle_y) {
            third += 1;
        } else if (robot.x > middle_x and robot.y > middle_y) {
            fourth += 1;
        }
    }
    return first * second * third * fourth;
}

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();

    const file = try std.fs.cwd().openFile("inputs/day14.txt", .{});
    defer file.close();
    const input = try file.readToEndAlloc(allocator, std.math.maxInt(usize));

    std.debug.print("Part1 result: {}\n", .{try part1(allocator, input, 101, 103)});
}

const test_input =
    \\p=0,4 v=3,-3
    \\p=6,3 v=-1,-3
    \\p=10,3 v=-1,2
    \\p=2,0 v=2,-1
    \\p=0,0 v=1,3
    \\p=3,0 v=-2,-2
    \\p=7,6 v=-1,-3
    \\p=3,0 v=-1,-2
    \\p=9,3 v=2,3
    \\p=7,3 v=-1,2
    \\p=2,4 v=2,-3
    \\p=9,5 v=-3,-3
;

test "Part 1 test" {
    try std.testing.expect(try part1(std.testing.allocator, test_input, 11, 7) == 12);
}
