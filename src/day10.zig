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
    row: usize,
    col: usize,
};

pub fn part1(allocator: Allocator, input: []const u8) !u64 {
    var m = try Matrix(u8).from(allocator, input);
    defer m.deinit();

    var result: u64 = 0;
    for (0..m.height) |r| {
        for (0..m.width) |c| {
            if (m.get(r, c) == '0') {
                var visited = std.AutoHashMap(Point, void).init(allocator);
                defer visited.deinit();
                var stack = std.ArrayList(Point).init(allocator);
                defer stack.deinit();
                try stack.append(Point{ .row = r, .col = c });
                try visited.put(Point{ .row = r, .col = c }, {});
                while (stack.popOrNull()) |p| {
                    if (m.get(p.row, p.col) == '9') {
                        result += 1;
                        continue;
                    }
                    if (p.row > 0 and !visited.contains(Point{ .row = p.row - 1, .col = p.col }) and m.get(p.row, p.col) + 1 == m.get(p.row - 1, p.col)) {
                        try visited.put(Point{ .row = p.row - 1, .col = p.col }, {});
                        try stack.append(Point{ .row = p.row - 1, .col = p.col });
                    }
                    if (p.col > 0 and !visited.contains(Point{ .row = p.row, .col = p.col - 1 }) and m.get(p.row, p.col) + 1 == m.get(p.row, p.col - 1)) {
                        try visited.put(Point{ .row = p.row, .col = p.col - 1 }, {});
                        try stack.append(Point{ .row = p.row, .col = p.col - 1 });
                    }
                    if (p.row < m.height - 1 and !visited.contains(Point{ .row = p.row + 1, .col = p.col }) and m.get(p.row, p.col) + 1 == m.get(p.row + 1, p.col)) {
                        try visited.put(Point{ .row = p.row + 1, .col = p.col }, {});
                        try stack.append(Point{ .row = p.row + 1, .col = p.col });
                    }
                    if (p.col < m.width - 1 and !visited.contains(Point{ .row = p.row, .col = p.col + 1 }) and m.get(p.row, p.col) + 1 == m.get(p.row, p.col + 1)) {
                        try visited.put(Point{ .row = p.row, .col = p.col + 1 }, {});
                        try stack.append(Point{ .row = p.row, .col = p.col + 1 });
                    }
                }
            }
        }
    }
    return result;
}

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();

    const file = try std.fs.cwd().openFile("inputs/day10.txt", .{});
    defer file.close();
    const input = try file.readToEndAlloc(allocator, std.math.maxInt(usize));

    std.debug.print("Part1 result: {}\n", .{try part1(allocator, input)});
}

const test_input =
    \\89010123
    \\78121874
    \\87430965
    \\96549874
    \\45678903
    \\32019012
    \\01329801
    \\10456732
;

test "Part 1 test" {
    try std.testing.expect(try part1(std.testing.allocator, test_input) == 36);
}
