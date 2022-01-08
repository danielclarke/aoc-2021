const std = @import("std");
const tokenize = std.mem.tokenize;

const Direction = enum {
    left,
    down,
    up,
    right,
};

fn neighbour(index: usize, direction: Direction, width: usize, height: usize) ?usize {
    switch (direction) {
        Direction.left => {
            if (index / width * width != index) {
                return index - 1;
            }
        },
        Direction.down => {
            if (index < width * (height - 1)) {
                return index + width;
            }
        },
        Direction.up => {
            if (index > width - 1) {
                return index - width;
            }
        },
        Direction.right => {
            if (index % width != width - 1) {
                return index + 1;
            }
        },
    }
    return null;
}

fn isMinima(index: usize, map: []const u8, width: usize, height: usize) bool {
    var left = false;
    var down = false;
    var up = false;
    var right = false;
    if (neighbour(index, Direction.left, width, height)) |neighbour_index| {
        left = map[neighbour_index] > map[index];
    } else {
        left = true;
    }
    if (neighbour(index, Direction.down, width, height)) |neighbour_index| {
        down = map[neighbour_index] > map[index];
    } else {
        down = true;
    }
    if (neighbour(index, Direction.up, width, height)) |neighbour_index| {
        up = map[neighbour_index] > map[index];
    } else {
        up = true;
    }
    if (neighbour(index, Direction.right, width, height)) |neighbour_index| {
        right = map[neighbour_index] > map[index];
    } else {
        right = true;
    }
    return left and down and up and right;
}

fn printMinimaMap(map: []const u8, width: usize, height: usize) void {
    for (map) |val, index| {
        if (isMinima(index, map, width, height)) {
            std.debug.print("*{}", .{val});
        } else {
            std.debug.print(" {}", .{val});
        }
        if (index % width == width - 1) {
            std.debug.print("\n", .{});
        }
    }
}

fn printMap(map: []const u8, width: usize) void {
    for (map) |val, index| {
        std.debug.print("{}", .{val});
        if (index % width == width - 1) {
            std.debug.print("\n", .{});
        }
    }
}

fn findMinima(path: []const u8) !void {
    var height_map = std.ArrayList(u8).init(std.testing.allocator);
    defer height_map.deinit();

    var extrema = std.ArrayList(u8).init(std.testing.allocator);
    defer extrema.deinit();

    var file = try std.fs.cwd().openFile(path, .{});
    defer file.close();

    var reader = file.reader();
    var buf: [1024]u8 = undefined;

    var width: usize = 0;
    var height: usize = 0;
    while (try reader.readUntilDelimiterOrEof(&buf, '\n')) |row| {
        for (row) |val| {
            width = row.len;
            try height_map.append(val - 48);
        }
    }
    height = height_map.items.len / width;

    std.debug.print("width: {}, height: {}\n", .{ width, height });
    printMinimaMap(height_map.items, width, height);
    std.debug.print("\n", .{});

    var risk: u16 = 0;
    for (height_map.items) |_, index| {
        if (isMinima(index, height_map.items, width, height)) {
            risk += 1 + height_map.items[index];
            try extrema.append(1 + height_map.items[index]);
        } else {
            try extrema.append('.');
        }
    }

    // print(extrema.items, width);
    std.debug.print("\n", .{});
    std.debug.print("risk: {}\n", .{risk});
}

fn floodFill(start_index: usize, map: []const u8, filled: []u8, width: usize, height: usize) u16 {
    filled[start_index] = 1;
    var count: u16 = 1;
    if (neighbour(start_index, Direction.left, width, height)) |index| {
        if (map[index] != 9 and filled[index] != 1) {
            count += floodFill(index, map, filled, width, height);
        }
    }
    if (neighbour(start_index, Direction.down, width, height)) |index| {
        if (map[index] != 9 and filled[index] != 1) {
            count += floodFill(index, map, filled, width, height);
        }
    }
    if (neighbour(start_index, Direction.up, width, height)) |index| {
        if (map[index] != 9 and filled[index] != 1) {
            count += floodFill(index, map, filled, width, height);
        }
    }
    if (neighbour(start_index, Direction.right, width, height)) |index| {
        if (map[index] != 9 and filled[index] != 1) {
            count += floodFill(index, map, filled, width, height);
        }
    }
    return count;
}

fn updateCounts(count: u16, biggestCounts: *[3]u32) void {
    if (count > biggestCounts[0]) {
        biggestCounts[2] = biggestCounts[1];
        biggestCounts[1] = biggestCounts[0];
        biggestCounts[0] = count;
    } else if (count > biggestCounts[1]) {
        biggestCounts[2] = biggestCounts[1];
        biggestCounts[1] = count;
    } else if (count > biggestCounts[2]) {
        biggestCounts[2] = count;
    }
}

fn findBiggestPools(path: []const u8) !void {
    var height_map = std.ArrayList(u8).init(std.testing.allocator);
    defer height_map.deinit();

    var filled = std.ArrayList(u8).init(std.testing.allocator);
    defer filled.deinit();

    var file = try std.fs.cwd().openFile(path, .{});
    defer file.close();

    var reader = file.reader();
    var buf: [1024]u8 = undefined;

    var width: usize = 0;
    var height: usize = 0;
    while (try reader.readUntilDelimiterOrEof(&buf, '\n')) |row| {
        for (row) |val| {
            width = row.len;
            try height_map.append(val - 48);
            try filled.append(0);
        }
    }
    height = height_map.items.len / width;
    var biggestCounts = [_]u32{0} ** 3;
    for (height_map.items) |val, index| {
        if (val != 9 and filled.items[index] != 1) {
            var count = floodFill(index, height_map.items, filled.items, width, height);
            updateCounts(count, &biggestCounts);
        }
    }
    printMap(height_map.items, width);
    std.debug.print("\n", .{});
    printMap(filled.items, width);
    std.debug.print("counts: {}, {}, {}\n", .{ biggestCounts[0], biggestCounts[1], biggestCounts[2] });
    std.debug.print("toal: {}\n", .{ biggestCounts[0] * biggestCounts[1] * biggestCounts[2] });
}

pub fn main() anyerror!void {
    try findBiggestPools("assets/test");
    // try findMinima("assets/test0");
    // try findMinima("assets/test1");
    // try findMinima("assets/test2");
    // try findMinima("assets/test3");
    // try findMinima("assets/test4");
    // try findMinima("assets/test5");
    // try findMinima("assets/test6");
    // try findMinima("assets/test7");
    // try findMinima("assets/test8");
    // try findMinima("assets/test9");
    try findBiggestPools("assets/data");
}

test "basic test" {
    try std.testing.expectEqual(10, 3 + 7);
}
