const std = @import("std");

pub fn part1(allocator: std.mem.Allocator, input: []const u8) !u32 {
    var result: u32 = 0;
    var map = std.AutoHashMap(struct { u8, u8 }, void).init(allocator);
    defer map.deinit();

    var it = std.mem.splitScalar(u8, input, '\n');
    while (it.next()) |line| {
        if (line.len == 0) break;
        var nums = std.mem.tokenizeScalar(u8, line, '|');
        const first = try std.fmt.parseInt(u8, nums.next().?, 10);
        const second = try std.fmt.parseInt(u8, nums.next().?, 10);
        try map.put(.{ first, second }, {});
    }
    outer: while (it.next()) |line| {
        if (line.len == 0) break;
        var list = std.ArrayList(u8).init(allocator);
        defer list.deinit();
        var nums = std.mem.tokenizeScalar(u8, line, ',');
        while (nums.next()) |num| {
            try list.append(try std.fmt.parseInt(u8, num, 10));
        }
        for (0..list.items.len - 1) |i| {
            for (i + 1..list.items.len) |j| {
                if (!map.contains(.{ list.items[i], list.items[j] })) continue :outer;
            }
        }
        result += list.items[list.items.len / 2];
    }
    return result;
}

const Map = std.AutoHashMap(struct { u8, u8 }, void);

fn fix(map: Map, list: []u8) void {
    for (0..list.len - 1) |i| {
        for (i + 1..list.len) |j| {
            if (!map.contains(.{ list[i], list[j] })) {
                const tmp = list[j];
                list[j] = list[i];
                list[i] = tmp;
            }
        }
    }
}

pub fn part2(allocator: std.mem.Allocator, input: []const u8) !u32 {
    var result: u32 = 0;
    var map = Map.init(allocator);
    defer map.deinit();

    var it = std.mem.splitScalar(u8, input, '\n');
    while (it.next()) |line| {
        if (line.len == 0) break;
        var nums = std.mem.tokenizeScalar(u8, line, '|');
        const first = try std.fmt.parseInt(u8, nums.next().?, 10);
        const second = try std.fmt.parseInt(u8, nums.next().?, 10);
        try map.put(.{ first, second }, {});
    }
    outer: while (it.next()) |line| {
        if (line.len == 0) break;
        var list = std.ArrayList(u8).init(allocator);
        defer list.deinit();
        var nums = std.mem.tokenizeScalar(u8, line, ',');
        while (nums.next()) |num| {
            try list.append(try std.fmt.parseInt(u8, num, 10));
        }
        for (0..list.items.len - 1) |i| {
            for (i + 1..list.items.len) |j| {
                if (!map.contains(.{ list.items[i], list.items[j] })) {
                    fix(map, list.items);
                    result += list.items[list.items.len / 2];
                    continue :outer;
                }
            }
        }
    }
    return result;
}
pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();

    const file = try std.fs.cwd().openFile("inputs/day05.txt", .{});
    defer file.close();
    const input = try file.readToEndAlloc(allocator, std.math.maxInt(usize));
    std.debug.print("Part1 result: {}\n", .{try part1(allocator, input)});
    std.debug.print("Part2 result: {}\n", .{try part2(allocator, input)});
}

const test_input =
    \\47|53
    \\97|13
    \\97|61
    \\97|47
    \\75|29
    \\61|13
    \\75|53
    \\29|13
    \\97|29
    \\53|29
    \\61|53
    \\97|53
    \\61|29
    \\47|13
    \\75|47
    \\97|75
    \\47|61
    \\75|61
    \\47|29
    \\75|13
    \\53|13
    \\
    \\75,47,61,53,29
    \\97,61,53,29,13
    \\75,29,13
    \\75,97,47,61,53
    \\61,13,29
    \\97,13,75,29,47
;

test "Part 1 test" {
    try std.testing.expect(try part1(std.testing.allocator, test_input) == 143);
}

test "Part 2 test" {
    try std.testing.expect(try part2(std.testing.allocator, test_input) == 123);
}
