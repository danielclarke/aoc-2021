const std = @import("std");
const tokenize = std.mem.tokenize;

const DAYS = 256;
const FISH_AGES = 7;
const EGG_AGES = 3;

pub fn main() anyerror!void {
    var file = try std.fs.cwd().openFile("assets/data", .{});
    defer file.close();

    var reader = file.reader();
    var buf: [1024]u8 = undefined;

    var num_fish: u64 = 0;
    var fishes = [_]u64{0} ** 7;
    var eggs = [_]u64{0} ** 3;

    var opt_fishs = try reader.readUntilDelimiterOrEof(&buf, '\n');
    if (opt_fishs) |data| {
        var it = tokenize(u8, data, ",");
        while (it.next()) |f| {
            var fish = try std.fmt.parseInt(u4, f, 10);
            fishes[fish] += 1;
            num_fish += 1;
        }
    }

    var day: u16 = 0;
    while (day <= DAYS) : (day += 1) {
        // var zero_index = day % FISH_AGES;
        var new_adult_index = (day + FISH_AGES - 1) % FISH_AGES;
        var hatch_index = day % EGG_AGES;
        var lay_index = (hatch_index + EGG_AGES - 1) % EGG_AGES;

        eggs[lay_index] += fishes[new_adult_index];
        fishes[new_adult_index] += eggs[hatch_index];
        num_fish += eggs[lay_index];
        eggs[hatch_index] = 0;

        // std.log.info("day {} num fish: {}", .{ day, num_fish});
        // std.log.info("day {} zero_index {}, new_adult_index {}", .{ day, zero_index, new_adult_index });
        // std.log.info("day {} hatch_index {}, lay_index {}", .{ day, hatch_index, lay_index });
        // std.log.info("0, 1, 2, 3, 4, 5, 6, 7, 8", .{});
        // std.log.info("{}, {}, {}, {}, {}, {}, {}, {}, {}", .{
        //     fishes[zero_index],
        //     fishes[(zero_index + 1) % FISH_AGES],
        //     fishes[(zero_index + 2) % FISH_AGES],
        //     fishes[(zero_index + 3) % FISH_AGES],
        //     fishes[(zero_index + 4) % FISH_AGES],
        //     fishes[(zero_index + 5) % FISH_AGES],
        //     fishes[(zero_index + 6) % FISH_AGES],
        //     // eggs[hatch_index],
        //     eggs[(hatch_index + 1) % EGG_AGES],
        //     eggs[(hatch_index + 2) % EGG_AGES],
        // });
    }
    std.log.info("num fish: {}", .{num_fish});
}

test "basic test" {
    try std.testing.expectEqual(10, 3 + 7);
}
