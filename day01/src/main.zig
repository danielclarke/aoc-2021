const std = @import("std");

const measurements = @import("data.zig").data;
const test_measurements = [_]u16{199, 200, 208, 210, 200, 207, 240, 269, 260, 263};

pub fn main() anyerror!void {
    // std.log.info("Increases: {}", .{count_increases(measurements[0..])});
    std.log.info("Increases: {}", .{count_sliding_window_increases(&measurements)});
}

fn count_increases(data: []const u16) u16 {
    var increases: u16 = 0;
    for(data[1..]) |d, i| {
        if (d > data[i]) {
            increases += 1;
        }
    }
    return increases;
}

fn sum(numbers: [] const u16) u16 {
    var result: u16 = 0;
    for(numbers) |number| {
        result += number;
    }
    return result;
}

fn count_sliding_window_increases(data: []const u16) u16 {
    var increases: u16 = 0;
    var i: u16 = 1;
    var prev: u16 = sum(data[0..3]);

    while (i + 3 <= data.len) : (i += 1) {
        var current = sum(data[i..i + 3]);
        if (current > prev) {
            increases += 1;
        }
        prev = current;
    }

    return increases;
}

test "basic test" {
    try std.testing.expectEqual(10, 3 + 7);
}
