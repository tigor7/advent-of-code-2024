const std = @import("std");

fn Matrix(comptime T: type) type {
    return struct {
        const Self = @This();
        buf: [][]const T,
        width: usize,
        height: usize,

        pub fn get(self: Self, row: usize, column: usize) T {
            return self.buf[row][column];
        }
    };
}

pub fn part1(allocator: std.mem.Allocator, input: []const u8) !u32 {
    var map = std.ArrayList([]const u8).init(allocator);
    defer map.deinit();
    var height: usize = 0;
    var width: usize = 0;

    var it = std.mem.tokenizeScalar(u8, input, '\n');
    while (it.next()) |line| {
        try map.append(line);
        height += 1;
        width = line.len;
    }
    var matrix = Matrix(u8){ .buf = map.items, .width = width, .height = height };
    var result: u32 = 0;
    // Rows
    for (0..matrix.height) |r| {
        for (0..matrix.width - 3) |c| {
            if (matrix.get(r, c) == 'X' and matrix.get(r, c + 1) == 'M' and matrix.get(r, c + 2) == 'A' and matrix.get(r, c + 3) == 'S') {
                result += 1;
            }
            if (matrix.get(r, c) == 'S' and matrix.get(r, c + 1) == 'A' and matrix.get(r, c + 2) == 'M' and matrix.get(r, c + 3) == 'X') {
                result += 1;
            }
        }
    }
    // Cols
    for (0..matrix.width) |c| {
        for (0..matrix.height - 3) |r| {
            if (matrix.get(r, c) == 'X' and matrix.get(r + 1, c) == 'M' and matrix.get(r + 2, c) == 'A' and matrix.get(r + 3, c) == 'S') {
                result += 1;
            }
            if (matrix.get(r, c) == 'S' and matrix.get(r + 1, c) == 'A' and matrix.get(r + 2, c) == 'M' and matrix.get(r + 3, c) == 'X') {
                result += 1;
            }
        }
    }
    // Diagonal
    for (0..matrix.height - 3) |r| {
        for (0..matrix.width - 3) |c| {
            if (matrix.get(r, c) == 'X' and matrix.get(r + 1, c + 1) == 'M' and matrix.get(r + 2, c + 2) == 'A' and matrix.get(r + 3, c + 3) == 'S') {
                result += 1;
            }
            if (matrix.get(r, c) == 'S' and matrix.get(r + 1, c + 1) == 'A' and matrix.get(r + 2, c + 2) == 'M' and matrix.get(r + 3, c + 3) == 'X') {
                result += 1;
            }
        }
    }
    // Other diagonal
    for (0..matrix.height - 3) |r| {
        for (3..matrix.width) |c| {
            if (matrix.get(r, c) == 'X' and matrix.get(r + 1, c - 1) == 'M' and matrix.get(r + 2, c - 2) == 'A' and matrix.get(r + 3, c - 3) == 'S') {
                result += 1;
            }
            if (matrix.get(r, c) == 'S' and matrix.get(r + 1, c - 1) == 'A' and matrix.get(r + 2, c - 2) == 'M' and matrix.get(r + 3, c - 3) == 'X') {
                result += 1;
            }
        }
    }

    return result;
}

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();

    var file = try std.fs.cwd().openFile("inputs/day04.txt", .{});
    defer file.close();
    const input = try file.readToEndAlloc(allocator, std.math.maxInt(usize));
    std.debug.print("Part1 result: {}\n", .{try part1(allocator, input)});
}

const test_input =
    \\MMMSXXMASM
    \\MSAMXMSMSA
    \\AMXSXMAAMM
    \\MSAMASMSMX
    \\XMASAMXAMM
    \\XXAMMXXAMA
    \\SMSMSASXSS
    \\SAXAMASAAA
    \\MAMMMXMMMM
    \\MXMXAXMASX
;
test "Part 1 test" {
    try std.testing.expect(try part1(std.testing.allocator, test_input) == 18);
}
