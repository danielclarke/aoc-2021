const std = @import("std");
const tokenize = std.mem.tokenize;

pub fn main() anyerror!void {
    
    var x: i32 = 0;
    var y: i32 = 0;
    var aim: i32 = 0;

    // var it = tokenize(u8, " abc def ghi ", " ");
    // while(it.next()) |token| {
    //     std.debug.print("{s}\n", .{token});
    // }

    var file = try std.fs.cwd().openFile("commands", .{});
    defer file.close();

    var reader = file.reader();
    var buf: [1024]u8 = undefined;
    while(try reader.readUntilDelimiterOrEof(&buf, '\n')) |line| {
        const cmdEnd: ?usize = for(line) |char, i| {
            if (char == ' ') break i;
        } else null;
        
        if (cmdEnd) |ce| {
            const cmd = line[0..ce];
            const mag = std.fmt.parseInt(i32, line[ce+1..], 10);
            if (cmd[0] == 'f') {
                x += try mag;
                y += aim * try mag;
            } else if (cmd[0] == 'd') {
                aim += try mag;
            } else if (cmd[0] == 'u') {
                aim -= try mag;
            }
            // std.debug.print("{s}\n", .{line[0..ce]});
            // std.debug.print("{}\n", .{std.fmt.parseInt(i32, line[ce+1..], 10)});
        }
    }
    std.debug.print("{}\n", .{aim});
    std.debug.print("{}\n", .{x});
    std.debug.print("{}\n", .{y});
    std.debug.print("{}\n", .{x * y});
}

// fn parse() {

// }

test "basic test" {
    try std.testing.expectEqual(10, 3 + 7);
}
