const std = @import("std");
const parseNumbers = @import("utils.zig").parseNumbers;
const Allocator = std.mem.Allocator;

fn evenDigits(num: u64) !bool {
    return (std.math.log10_int(num) + 1) % 2 == 0;
}

fn blink(list: *std.ArrayList(u64)) !void {
    const len = list.items.len;
    for (0..len) |i| {
        if (list.items[i] == 0) {
            list.items[i] = 1;
        } else if (try evenDigits(list.items[i])) {
            const halve = std.math.pow(u64, 10, (std.math.log10_int(list.items[i]) + 1) / 2);
            const first = list.items[i] / halve;
            const second = list.items[i] % halve;
            list.items[i] = first;
            try list.append(second);
        } else {
            list.items[i] = list.items[i] * 2024;
        }
    }
}

pub fn part1(allocator: Allocator, input: []const u8) !u64 {
    const nums = try parseNumbers(u64, allocator, input, " \n");
    var list = std.ArrayList(u64).init(allocator);
    defer allocator.free(nums);
    defer list.deinit();

    try list.appendSlice(nums);
    for (0..25) |_| {
        try blink(&list);
    }
    return list.items.len;
}

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();

    const file = try std.fs.cwd().openFile("inputs/day11.txt", .{});
    defer file.close();
    const input = try file.readToEndAlloc(allocator, std.math.maxInt(usize));

    std.debug.print("Part1 result: {}\n", .{try part1(allocator, input)});
}

const test_input = "125 17";

test "Part 1 test" {
    try std.testing.expect(try part1(std.testing.allocator, test_input) == 55312);
}
