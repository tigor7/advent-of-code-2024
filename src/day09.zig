const std = @import("std");
const Allocator = std.mem.Allocator;

pub fn part1(allocator: Allocator, input: []const u8) !u64 {
    var list = std.ArrayList(?u64).init(allocator);
    defer list.deinit();
    var id: u32 = 0;
    for (input, 0..) |c, i| {
        if (c < 48 or c > 57) break;
        const n: usize = c - 48;
        if (i % 2 == 0) {
            for (0..n) |_| {
                try list.append(id);
            }
            id += 1;
        } else {
            for (0..n) |_| {
                try list.append(null);
            }
        }
    }
    var i = list.items.len;
    while (i > 0) {
        i -= 1;
        if (list.items[i] == null) continue;
        for (0..i) |j| {
            if (list.items[j] == null) {
                list.items[j] = list.items[i];
                list.items[i] = null;
                break;
            }
        }
    }
    var result: u64 = 0;
    for (list.items, 0..) |val, j| {
        if (val == null) break;
        result += @as(u64, @intCast(j)) * val.?;
    }
    return result;
}

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();

    const file = try std.fs.cwd().openFile("inputs/day09.txt", .{});
    defer file.close();
    const input = try file.readToEndAlloc(allocator, std.math.maxInt(usize));

    std.debug.print("Part1 result: {}\n", .{try part1(allocator, input)});
}

const test_input = "2333133121414131402";

test "Part 1 test" {
    try std.testing.expect(try part1(std.testing.allocator, test_input) == 1928);
}
