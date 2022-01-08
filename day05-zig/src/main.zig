const std = @import("std");
const tokenize = std.mem.tokenize;

const Point = struct { x: u32, y: u32 };

const Segment = struct { p0: Point, p1: Point };

fn horizontal(segment: Segment) bool {
    return segment.p0.x == segment.p1.x;
}

fn vertical(segment: Segment) bool {
    return segment.p0.x == segment.p1.x;
}

fn intersection(segment_a: Segment, segment_b: Segment) ?Point {
    var x1 = segment_a.p0.x;
    var x2 = segment_a.p1.x;
    var y1 = segment_a.p0.y;
    var y2 = segment_a.p1.y;

    var x3 = segment_b.p0.x;
    var x4 = segment_b.p1.x;
    var y3 = segment_b.p0.y;
    var y4 = segment_b.p1.y;

    var a = (x1 - x3) * (y3 - y4) - (y1 - y3) * (x3 - x4);
    var b = (x1 - x2) * (y3 - y4) - (y1 - y2) * (x3 - x4);

    var t = a / b;

    var c = (x1 - x3) * (y1 - y2) - (y1 - y3) * (x1 - x2);
    var d = (x1 - x2) * (y3 - y4) - (y1 - y2) * (x3 - x4);

    var u = c / d;

    if (0 <= t and t <= 1 and 0 <= u and u <= 1) {
        return Point{
            .x = x1 + t * (x2 - x1),
            .y = y1 + t * (y2 - y1),
        };
    }

    return null;
}

pub fn main() anyerror!void {
    var file = try std.fs.cwd().openFile("assets/test_data.txt", .{});
    defer file.close();

    var segments = std.ArrayList(Segment).init(std.testing.allocator);
    defer segments.deinit();

    var points = std.ArrayList(Point).init(std.testing.allocator);
    defer points.deinit();

    var reader = file.reader();
    var buf: [1024]u8 = undefined;
    var max_x: u32 = 0;
    var max_y: u32 = 0;
    while (try reader.readUntilDelimiterOrEof(&buf, '\n')) |line| {
        var it = tokenize(u8, line, " -> ");
        var segment_ends: [2]Point = undefined;
        var i: u8 = 0;
        while (it.next()) |coord| {
            var vals = tokenize(u8, coord, ",");
            var coords: [2]u32 = undefined;
            var j: u8 = 0;
            while (vals.next()) |val| {
                coords[j] = try std.fmt.parseInt(u32, val, 10);
                j += 1;
            }
            segment_ends[i] = Point{
                .x = coords[0],
                .y = coords[1],
            };
            try points.append(segment_ends[i]);
            max_x = if (coords[0] > max_x) coords[0] else max_x;
            max_y = if (coords[1] > max_y) coords[1] else max_y;
            i += 1;
        }
        try segments.append(Segment{
            .p0 = segment_ends[0],
            .p1 = segment_ends[1],
        });
    }

    var map = std.ArrayList(u16).init(std.testing.allocator);
    defer map.deinit();

    std.log.info("x: {}, y: {}", .{max_x, max_y});
}

test "basic test" {
    try std.testing.expectEqual(10, 3 + 7);
}
