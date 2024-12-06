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

const Direction = enum {
    up,
    down,
    right,
    left,
};

const Position = struct {
    row: usize,
    col: usize,

    pub fn newPosition(self: *Position, dir: Direction) Position {
        var new_row = self.row;
        var new_col = self.col;
        switch (dir) {
            .up => new_row -= 1,
            .down => new_row += 1,
            .left => new_col -= 1,
            .right => new_col += 1,
        }
        return .{
            .row = new_row,
            .col = new_col,
        };
    }
};

pub fn part1(allocator: std.mem.Allocator, input: []const u8) !u32 {
    var m = try Matrix(u8).from(allocator, input);
    defer m.deinit();
    var result: u32 = 1;

    var guard_position: Position = undefined;
    var dir: Direction = .up;
    for (0..m.height) |r| {
        for (0..m.width) |c| {
            if (m.get(r, c) == '^') {
                guard_position = .{ .row = r, .col = c };
                m.set(r, c, 'X');
            }
        }
    }

    while (true) {
        const new_pos = guard_position.newPosition(dir);
        if (m.outOfBounds(new_pos.row, new_pos.col)) break;
        if (m.get(new_pos.row, new_pos.col) == '#') {
            dir = switch (dir) {
                .up => .right,
                .down => .left,
                .left => .up,
                .right => .down,
            };
            continue;
        }
        guard_position = new_pos;
        if (m.get(new_pos.row, new_pos.col) == 'X') continue;
        m.set(new_pos.row, new_pos.col, 'X');
        result += 1;
    }

    return result;
}

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();

    const file = try std.fs.cwd().openFile("inputs/day06.txt", .{});
    defer file.close();

    const input = try file.readToEndAlloc(allocator, std.math.maxInt(usize));
    std.debug.print("Part1 result: {}\n", .{try part1(allocator, input)});
}

const test_input =
    \\....#.....
    \\.........#
    \\..........
    \\..#.......
    \\.......#..
    \\..........
    \\.#..^.....
    \\........#.
    \\#.........
    \\......#...
;

test "Part 1 tes" {
    try std.testing.expect(try part1(std.testing.allocator, test_input) == 41);
}
