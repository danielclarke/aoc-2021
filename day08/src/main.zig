const std = @import("std");
const tokenize = std.mem.tokenize;

fn contains(comptime T: type, a: []const T, b: []const T) bool {
    for (b) |i| {
        for (a) |j| {
            if (i == j) {
                break;
            }
        } else {
            return false;
        }
    }
    return true;
}

fn copy(comptime T: type, a: []const T, b: []T) void {
    for (a) |val, i| {
        b[i] = val;
    }
}

fn pow(comptime T: type, base: T, exponent: u8) T {
    var i: u8 = 0;
    var result: T = 1;
    while (i < exponent) : (i += 1) {
        result *= base;
    }
    return result;
}

pub fn main() anyerror!void {
    var file = try std.fs.cwd().openFile("assets/data", .{});
    defer file.close();

    var reader = file.reader();
    var buf: [1024]u8 = undefined;

    var sum: u32 = 0;

    while (try reader.readUntilDelimiterOrEof(&buf, '\n')) |data| {
        var it = tokenize(u8, data, " ");

        var zero: [6]u8 = undefined;
        var one: [2]u8 = undefined;
        var two: [5]u8 = undefined;
        var three: [5]u8 = undefined;
        var four: [4]u8 = undefined;
        var five: [5]u8 = undefined;
        var six: [6]u8 = undefined;
        var seven: [3]u8 = undefined;
        var eight: [7]u8 = undefined;
        var nine: [6]u8 = undefined;

        var five_index: usize = 0;
        var fives = [3][5]u8{ [_]u8{0} ** 5, [_]u8{0} ** 5, [_]u8{0} ** 5 };

        var six_index: usize = 0;
        var sixes = [3][6]u8{ undefined, undefined, undefined };

        var i: u8 = 0;
        while (it.next()) |token| {
            // one
            // four
            // seven
            // eight
            // three contains seven
            // nine contains four
            // five is contained by nine
            // two is remainder of fives
            // zero contains seven
            // six is remainder of sixes
            if (i <= 9) {
                switch (token.len) {
                    2 => {
                        copy(u8, token, &one);
                    },
                    3 => {
                        copy(u8, token, &seven);
                    },
                    4 => {
                        copy(u8, token, &four);
                    },
                    5 => {
                        copy(u8, token, &fives[five_index]);
                        five_index += 1;
                    },
                    6 => {
                        copy(u8, token, &sixes[six_index]);
                        six_index += 1;
                    },
                    7 => {
                        copy(u8, token, &eight);
                    },
                    else => {},
                }
            } else if (i == 10) {
                for (sixes) |f| {
                    if (contains(u8, &f, &four)) {
                        copy(u8, &f, &nine);
                    } else if (contains(u8, &f, &seven)) {
                        copy(u8, &f, &zero);
                    } else {
                        copy(u8, &f, &six);
                    }
                }
                for (fives) |f| {
                    if (contains(u8, &f, &seven)) {
                        copy(u8, &f, &three);
                    } else if (contains(u8, &nine, &f)) {
                        copy(u8, &f, &five);
                    } else {
                        copy(u8, &f, &two);
                    }
                }

                // std.debug.print("zero: {s}\n", .{zero});
                // std.debug.print("one: {s}\n", .{one});
                // std.debug.print("two: {s}\n", .{two});
                // std.debug.print("three: {s}\n", .{three});
                // std.debug.print("four: {s}\n", .{four});
                // std.debug.print("five: {s}\n", .{five});
                // std.debug.print("six: {s}\n", .{six});
                // std.debug.print("seven: {s}\n", .{seven});
                // std.debug.print("eight: {s}\n", .{eight});
                // std.debug.print("nine: {s}\n", .{nine});
                // std.debug.print("~~~~~~~\n", .{});
            } else {
                var magnitude = pow(u16, 10, 14 - i);
                switch (token.len) {
                    2 => {}, // token = 1, magnitude *= 1;
                    3 => {
                        magnitude *= 7;
                    },
                    4 => {
                        magnitude *= 4;
                    },
                    5 => {
                        if (contains(u8, token, &two)) {
                            magnitude *= 2;
                        } else if (contains(u8, token, &three)) {
                            magnitude *= 3;
                        } else {
                            magnitude *= 5;
                        }
                    },
                    6 => {
                        if (contains(u8, token, &zero)) {
                            magnitude *= 0;
                        } else if (contains(u8, token, &six)) {
                            magnitude *= 6;
                        } else {
                            magnitude *= 9;
                        }
                    },
                    7 => {
                        magnitude *= 8;
                    },
                    else => {},
                }
                sum += magnitude;
            }
            i += 1;
        }
    }
    std.debug.print("sum: {}\n", .{sum});
}

test "basic test" {
    try std.testing.expectEqual(10, 3 + 7);
}
