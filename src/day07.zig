const std = @import("std");
const parseNumbers = @import("utils.zig").parseNumbers;
const Allocator = std.mem.Allocator;

const Operator = enum { add, multiply };

const Combinations = struct {
    current: []Operator,
    allocator: Allocator,
    last: bool = false,
    pub fn init(allocator: Allocator, size: usize) !Combinations {
        const slice = try allocator.alloc(Operator, size);
        for (0..slice.len) |i| slice[i] = .multiply;
        return .{
            .current = slice,
            .allocator = allocator,
        };
    }

    pub fn deinit(self: Combinations) void {
        self.allocator.free(self.current);
    }

    pub fn next(self: *Combinations) ?[]Operator {
        if (self.last) return null;
        var i = self.current.len - 1;
        while (i >= 0) : (i -= 1) {
            if (self.current[i] == .add) {
                self.current[i] = .multiply;
                break;
            }
            self.current[i] = .add;
            if (i == 0) break;
        }
        for (0..self.current.len) |j| {
            if (self.current[j] == .add) break;
        } else self.last = true;
        return self.current;
    }
};

const OperatorsExtra = enum { add, multiply, concat };

const CombinationsExtra = struct {
    current: []OperatorsExtra,
    allocator: Allocator,
    last: bool = false,
    pub fn init(allocator: Allocator, size: usize) !CombinationsExtra {
        const slice = try allocator.alloc(OperatorsExtra, size);
        for (0..slice.len) |i| slice[i] = .concat;
        return .{
            .current = slice,
            .allocator = allocator,
        };
    }

    pub fn deinit(self: CombinationsExtra) void {
        self.allocator.free(self.current);
    }

    pub fn next(self: *CombinationsExtra) ?[]OperatorsExtra {
        if (self.last) return null;
        var i = self.current.len - 1;
        while (i >= 0) : (i -= 1) {
            if (self.current[i] == .add) {
                self.current[i] = .multiply;
                break;
            } else if (self.current[i] == .multiply) {
                self.current[i] = .concat;
                break;
            }
            self.current[i] = .add;
            if (i == 0) break;
        }
        for (0..self.current.len) |j| {
            if (self.current[j] == .add or self.current[j] == .multiply) break;
        } else self.last = true;
        return self.current;
    }
};
pub fn part1(allocator: Allocator, input: []const u8) !u64 {
    var result: u64 = 0;

    var it = std.mem.tokenizeScalar(u8, input, '\n');
    while (it.next()) |line| {
        const nums = try parseNumbers(u64, allocator, line, ": ");
        defer allocator.free(nums);
        var combs = try Combinations.init(allocator, nums.len - 2);
        defer combs.deinit();

        while (combs.next()) |comb| {
            var sum: u64 = nums[1];
            for (2..nums.len) |i| {
                sum = switch (comb[i - 2]) {
                    .add => sum + nums[i],
                    .multiply => sum * nums[i],
                };
            }
            if (sum == nums[0]) {
                result += nums[0];
                break;
            }
        }
    }

    return result;
}

pub fn part2(allocator: Allocator, input: []const u8) !u64 {
    var result: u64 = 0;

    var it = std.mem.tokenizeScalar(u8, input, '\n');
    while (it.next()) |line| {
        const nums = try parseNumbers(u64, allocator, line, ": ");
        defer allocator.free(nums);
        var combs = try CombinationsExtra.init(allocator, nums.len - 2);
        defer combs.deinit();

        while (combs.next()) |comb| {
            var sum: u64 = nums[1];
            for (2..nums.len) |i| {
                switch (comb[i - 2]) {
                    .add => {
                        sum += nums[i];
                    },
                    .multiply => {
                        sum *= nums[i];
                    },
                    .concat => {
                        const slice = try std.fmt.allocPrint(allocator, "{d}{d}", .{ sum, nums[i] });
                        defer allocator.free(slice);
                        sum = try std.fmt.parseInt(u64, slice, 10);
                    },
                }
            }

            if (sum == nums[0]) {
                result += nums[0];
                break;
            }
        }
    }
    std.debug.print("Result: {}\n", .{result});
    return result;
}
pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();

    const file = try std.fs.cwd().openFile("inputs/day07.txt", .{});
    defer file.close();
    const input = try file.readToEndAlloc(allocator, std.math.maxInt(usize));

    std.debug.print("Part1 result: {}\n", .{try part1(allocator, input)});
    std.debug.print("Part2 result: {}\n", .{try part2(allocator, input)}); // took like 30min .-.
}

const test_input =
    \\190: 10 19
    \\3267: 81 40 27
    \\83: 17 5
    \\156: 15 6
    \\7290: 6 8 6 15
    \\161011: 16 10 13
    \\192: 17 8 14
    \\21037: 9 7 18 13
    \\292: 11 6 16 20
;
test "Part 1 test" {
    try std.testing.expect(try part1(std.testing.allocator, test_input) == 3749);
}

test "Part 2 test" {
    try std.testing.expect(try part2(std.testing.allocator, test_input) == 11387);
}
