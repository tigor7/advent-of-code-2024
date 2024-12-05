const std = @import("std");
const Allocator = std.mem.Allocator;
const SplitIterator = std.mem.SplitIterator(u8, .scalar);

fn parseNumbers(comptime T: type, allocator: Allocator, str: []const u8, sep: u8) ![]T {
    var list = std.ArrayList(T).init(allocator);

    var it = std.mem.tokenizeScalar(u8, str, sep);
    while (it.next()) |raw| {
        const num = try std.fmt.parseInt(T, raw, 10);
        try list.append(num);
    }
    return list.toOwnedSlice();
}

const HashSet = std.AutoHashMap(struct { u8, u8 }, void);

const OrderingRules = struct {
    rules: HashSet,
    allocator: Allocator,

    pub fn init(allocator: Allocator) OrderingRules {
        return .{
            .allocator = allocator,
            .rules = HashSet.init(allocator),
        };
    }

    pub fn deinit(self: *OrderingRules) void {
        self.rules.deinit();
    }

    pub fn read(self: *OrderingRules, it: *SplitIterator) !void {
        while (it.next()) |line| {
            if (line.len == 0) return;
            const nums = try parseNumbers(u8, self.allocator, line, '|');
            defer self.allocator.free(nums);
            try self.rules.put(.{ nums[0], nums[1] }, {});
        }
    }

    pub fn valid(self: OrderingRules, nums: []u8) bool {
        for (0..nums.len - 1) |i| {
            for (i + 1..nums.len) |j| {
                if (!self.rules.contains(.{ nums[i], nums[j] })) return false;
            }
        }
        return true;
    }

    pub fn fix(self: OrderingRules, nums: []u8) void {
        for (0..nums.len - 1) |i| {
            for (i + 1..nums.len) |j| {
                if (!self.rules.contains(.{ nums[i], nums[j] })) {
                    const tmp = nums[j];
                    nums[j] = nums[i];
                    nums[i] = tmp;
                }
            }
        }
    }
};

pub fn part1(allocator: Allocator, input: []const u8) !u32 {
    var result: u32 = 0;
    var ordering_rules = OrderingRules.init(allocator);
    defer ordering_rules.deinit();

    var it = std.mem.splitScalar(u8, input, '\n');
    try ordering_rules.read(&it);

    while (it.next()) |line| {
        if (line.len == 0) break;
        const nums = try parseNumbers(u8, allocator, line, ',');
        defer allocator.free(nums);
        if (ordering_rules.valid(nums)) {
            result += nums[nums.len / 2];
        }
    }
    return result;
}

pub fn part2(allocator: Allocator, input: []const u8) !u32 {
    var result: u32 = 0;
    var ordering_rules = OrderingRules.init(allocator);
    defer ordering_rules.deinit();

    var it = std.mem.splitScalar(u8, input, '\n');
    try ordering_rules.read(&it);

    while (it.next()) |line| {
        if (line.len == 0) break;

        const nums = try parseNumbers(u8, allocator, line, ',');
        defer allocator.free(nums);

        if (!ordering_rules.valid(nums)) {
            ordering_rules.fix(nums);
            result += nums[nums.len / 2];
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
