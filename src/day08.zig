const std = @import("std");
const Allocator = std.mem.Allocator;

fn Matrix(comptime T: type) type {
    return struct {
        const Self = @This();

        allocator: Allocator,
        buf: [][]T,
        width: usize,
        height: usize,

        pub fn from(allocator: Allocator, input: []const u8) !Self {
            var list = std.ArrayList([]u8).init(allocator);
            var height: usize = 0;
            var width: usize = 0;

            var it = std.mem.tokenizeScalar(u8, input, '\n');
            while (it.next()) |line| {
                try list.append(try allocator.dupe(u8, line));
                height += 1;
                width = line.len;
            }
            return .{
                .allocator = allocator,
                .buf = try list.toOwnedSlice(),
                .width = width,
                .height = height,
            };
        }

        pub fn deinit(self: *Self) void {
            for (self.buf) |slice| {
                self.allocator.free(slice);
            }
            self.allocator.free(self.buf);
        }

        pub fn get(self: Self, row: usize, column: usize) T {
            return self.buf[row][column];
        }

        pub fn set(self: *Self, row: usize, column: usize, value: T) void {
            self.buf[row][column] = value;
        }

        pub fn outOfBounds(self: Self, row: usize, column: usize) bool {
            return row < 0 or row >= self.height or column < 0 or column >= self.width;
        }
    };
}

const Point = struct {
    row: i32,
    col: i32,
};

pub fn part1(allocator: Allocator, input: []const u8) !u32 {
    var m = try Matrix(u8).from(allocator, input);

    var set = std.AutoHashMap(Point, void).init(allocator);
    defer set.deinit();
    defer m.deinit();

    for (0..m.height) |r| {
        for (0..m.width) |c| {
            if (m.get(r, c) == '.') continue;

            for (r..m.height) |r2| {
                for (0..m.width) |c2| {
                    if (r == r2 and c2 <= c) continue;
                    if (m.get(r, c) != m.get(r2, c2)) continue;
                    const r_diff: i32 = @intCast(r2 - r);
                    const c_diff: i32 = @intCast(if (c < c2) c2 - c else c - c2);

                    const p1 = Point{ .row = @as(i32, @intCast(r)) - r_diff, .col = if (c < c2) @as(i32, @intCast(c)) - c_diff else @as(i32, @intCast(c)) + c_diff };
                    const p2 = Point{ .row = @as(i32, @intCast(r2)) + r_diff, .col = if (c < c2) @as(i32, @intCast(c2)) + c_diff else @as(i32, @intCast(c2)) - c_diff };

                    if (p1.row >= 0 and p1.row < m.height and p1.col >= 0 and p1.col < m.width) {
                        try set.put(p1, {});
                    }
                    if (p2.row >= 0 and p2.row < m.height and p2.col >= 0 and p2.col < m.width) {
                        try set.put(p2, {});
                    }
                }
            }
        }
    }
    return set.count();
}

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();

    const file = try std.fs.cwd().openFile("inputs/day08.txt", .{});
    defer file.close();
    const input = try file.readToEndAlloc(allocator, std.math.maxInt(usize));

    std.debug.print("Part1 result: {}\n", .{try part1(allocator, input)});
}

const test_input =
    \\............
    \\........0...
    \\.....0......
    \\.......0....
    \\....0.......
    \\......A.....
    \\............
    \\............
    \\........A...
    \\.........A..
    \\............
    \\............
;

test "Part 1 test" {
    try std.testing.expect(try part1(std.testing.allocator, test_input) == 14);
}
