const std = @import("std");
const Vector = std.meta.Vector;

fn print(comptime T: type, arry: []T, width: usize) void {
    var i: usize = 0;
    for (arry) |val| {
        std.debug.print("{} ", .{val});
        i += 1;
        if (i == width) {
            std.debug.print("\n", .{});
            i = 0;
        }
    }
}

fn tick(comptime len: u8, octos: *Vector(len, u8)) void {
    const one: u8 = 1;
    octos.* += @splat(len, one);
}

fn shiftMask(comptime len: u8, comptime width: u8, shift_x: i8, shift_y: i8) [len]i8 {
    var mask = [_]i8{-1} ** len;

    var abs_shift_x: u8 = 0;
    var abs_shift_y: u8 = 0;

    if (shift_x < 0) {
        abs_shift_x = @intCast(u8, shift_x * -1);
    } else {
        abs_shift_x = @intCast(u8, shift_x);
    }

    if (shift_y < 0) {
        abs_shift_y = @intCast(u8, shift_y * -1);
    } else {
        abs_shift_y = @intCast(u8, shift_y);
    }

    var i: u8 = 0;
    while (i < len) : (i += 1) {
        mask[i] = @intCast(i8, i) - shift_x - (shift_y * @intCast(i8, width));
        if (shift_x < 0 and width - i % width <= abs_shift_x) {
            mask[i] = -1;
        } else if (shift_x > 0 and i % width < abs_shift_x) {
            mask[i] = -1;
        }
        if (shift_y < 0 and i >= len - width * abs_shift_y) {
            mask[i] = -1;
        } else if (shift_y > 0 and i < width * abs_shift_y) {
            mask[i] = -1;
        }
    }

    return mask;
}

fn flashEnergy(comptime len: u8, comptime width: u8, tens: Vector(len, u8)) Vector(len, u8) {
    const zero: u8 = 0;
    const zeroes: Vector(len, u8) = @splat(len, zero);

    var mask: Vector(len, u8) = @splat(len, zero);

    comptime var shift_masks = [8]Vector(len, i8){
        shiftMask(len, width, -1, -1),
        shiftMask(len, width, 0, -1),
        shiftMask(len, width, 1, -1),
        shiftMask(len, width, -1, 0),
        shiftMask(len, width, 1, 0),
        shiftMask(len, width, -1, 1),
        shiftMask(len, width, 0, 1),
        shiftMask(len, width, 1, 1),
    };

    mask += @shuffle(u8, tens, zeroes, shift_masks[0]);
    mask += @shuffle(u8, tens, zeroes, shift_masks[1]);
    mask += @shuffle(u8, tens, zeroes, shift_masks[2]);
    mask += @shuffle(u8, tens, zeroes, shift_masks[3]);
    mask += @shuffle(u8, tens, zeroes, shift_masks[4]);
    mask += @shuffle(u8, tens, zeroes, shift_masks[5]);
    mask += @shuffle(u8, tens, zeroes, shift_masks[6]);
    mask += @shuffle(u8, tens, zeroes, shift_masks[7]);

    return mask;
}

fn flash(comptime len: u8, comptime width: u8, octos: *Vector(len, u8)) u8 {
    const ten: u8 = 10;
    const one: u8 = 1;

    var tens = @minimum(@splat(len, one), @divFloor(octos.*, @splat(len, ten)));
    var flashed_mask: Vector(len, u8) = [_]u8{1} ** len;

    while(@reduce(.Add, tens) > 0) {
        var flash_energy = flashEnergy(len, width, tens);
        
        octos.* += flash_energy;
        flashed_mask &= ~tens;

        tens = @minimum(@splat(len, one), @divFloor(octos.*, @splat(len, ten))) * flashed_mask;
    }
    octos.* *= flashed_mask;

    var num_flashed = @reduce(.Add, @splat(len, one) - flashed_mask);
    return num_flashed;
}

fn run(comptime width: u8, path: []const u8) !void {
    @setEvalBranchQuota(10000);
    const len: u8 = width * width;

    var file = try std.fs.cwd().openFile(path, .{});
    defer file.close();
    var reader = file.reader();
    var buf: [1024]u8 = undefined;
    var arry: [len]u8 = undefined;
    var octos: Vector(len, u8) = undefined;
    var i: usize = 0;
    while (try reader.readUntilDelimiterOrEof(&buf, '\n')) |row| {
        for (row) |char| {
            arry[i] = char - 48;
            i += 1;
        }
    }

    std.debug.print("octos:\n", .{});
    print(u8, &arry, width);
    std.debug.print("\n", .{});

    i = 0;
    var total_flashed: u32 = 0;
    while (true) : (i += 1) {
        octos = arry;
        tick(len, &octos);

        var num_flashed: u8 = flash(len, width, &octos);
        total_flashed += num_flashed;
        
        arry = octos;
        std.debug.print("flashed octos:\n", .{});
        print(u8, &arry, width);
        std.debug.print("\n", .{});

        if (num_flashed == len) {
            std.debug.print("in sync at: {}\n", .{i});
            break;
        }
    }
}

pub fn main() anyerror!void {
    // try run(5, "assets/demo");
    // try run(10, "assets/test");
    try run(10, "assets/data");
}

test "basic test" {
    try std.testing.expectEqual(10, 3 + 7);
}
