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

fn newPoint(row: usize, col: usize) Point {
    return .{
        .row = row,
        .col = col,
    };
}

const HashSet = std.AutoHashMap(Point, void);

pub fn part1(allocator: Allocator, input: []const u8) !u64 {
    var result: u64 = 0;
    var m = try Matrix(u8).from(allocator, input);
    var visited = HashSet.init(allocator);
    var list = std.ArrayList(Point).init(allocator);
    defer list.deinit();
    defer m.deinit();
    defer visited.deinit();
    for (0..m.height) |r| {
        for (0..m.width) |c| {
            const p = newPoint(r, c);
            if (!visited.contains(p)) {
                var area: u64 = 0;
                var perimeter: u64 = 0;
                list.clearRetainingCapacity();
                try list.append(p);
                try visited.put(p, {});
                while (list.popOrNull()) |curr| {
                    area += 1;
                    if (curr.row == 0) {
                        perimeter += 1;
                    } else {
                        if (m.get(curr.row - 1, curr.col) != m.get(r, c)) {
                            perimeter += 1;
                        } else {
                            const neighbor = newPoint(curr.row - 1, curr.col);
                            if (!visited.contains(neighbor)) {
                                try visited.put(neighbor, {});
                                try list.append(neighbor);
                            }
                        }
                    }
                    if (curr.row == m.height - 1) {
                        perimeter += 1;
                    } else {
                        if (m.get(curr.row + 1, curr.col) != m.get(r, c)) {
                            perimeter += 1;
                        } else {
                            const neighbor = newPoint(curr.row + 1, curr.col);
                            if (!visited.contains(neighbor)) {
                                try visited.put(neighbor, {});
                                try list.append(neighbor);
                            }
                        }
                    }
                    if (curr.col == 0) {
                        perimeter += 1;
                    } else {
                        if (m.get(curr.row, curr.col - 1) != m.get(r, c)) {
                            perimeter += 1;
                        } else {
                            const neighbor = newPoint(curr.row, curr.col - 1);
                            if (!visited.contains(neighbor)) {
                                try visited.put(neighbor, {});
                                try list.append(neighbor);
                            }
                        }
                    }
                    if (curr.col == m.width - 1) {
                        perimeter += 1;
                    } else {
                        if (m.get(curr.row, curr.col + 1) != m.get(r, c)) {
                            perimeter += 1;
                        } else {
                            const neighbor = newPoint(curr.row, curr.col + 1);
                            if (!visited.contains(neighbor)) {
                                try visited.put(neighbor, {});
                                try list.append(neighbor);
                            }
                        }
                    }
                }
                result += area * perimeter;
            }
        }
    }
    return result;
}

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();

    const file = try std.fs.cwd().openFile("inputs/day12.txt", .{});
    defer file.close();
    const input = try file.readToEndAlloc(allocator, std.math.maxInt(usize));

    std.debug.print("Part1 result: {}\n", .{try part1(allocator, input)});
}

const test_input =
    \\RRRRIICCFF
    \\RRRRIICCCF
    \\VVRRRCCFFF
    \\VVRCCCJFFF
    \\VVVVCJJCFE
    \\VVIVCCJJEE
    \\VVIIICJJEE
    \\MIIIIIJJEE
    \\MIIISIJEEE
    \\MMMISSJEEE
;

test "Part 1 test" {
    try std.testing.expect(try part1(std.testing.allocator, test_input) == 1930);
}
